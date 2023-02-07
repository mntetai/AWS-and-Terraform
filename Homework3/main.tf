module "vpc" {
  source = "./modules/vpc"
}

# Instances #
resource "aws_instance" "nginx" {
  count                  = var.nginx_instances_count
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[count.index % module.vpc.private_subnet_count]
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % 2]
  key_name               = var.key_name
  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }
  user_data = <<EOF
  #!/bin/bash
  sudo amazon-linux-extras install nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  sudo echo "<html><head><title>Grandpa's Whiskey</title></head><body>Welcome to Grandpa's Whiskey <br> Host - $(hostname)</body></html>" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name    = "nginx-${count.index}"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}

resource "aws_instance" "db" {
  count                  = var.db_instances_count
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnets[count.index % module.vpc.private_subnet_count]
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index % 2]
  key_name               = var.key_name
  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  user_data = <<EOF
  #!/bin/bash
  cd ~
  echo "this is a db server${count.index}" >> db.txt
EOF 
  tags = {
    Name    = "db-${count.index}"
    Owner   = "Etai Tavor"
    Purpose = "db"
  }
}