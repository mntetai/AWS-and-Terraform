# Instances #
resource "aws_instance" "nginx" {
  count                  = var.nginx_instances_count
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.nginx_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index]
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
  sudo echo "<html><head><title>Grandpa's Whiskey${count.index}</title></head><body>Welcome to Grandpa's Whiskey</body></html>" > /usr/share/nginx/html/index.html
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
  subnet_id              = aws_subnet.db_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[count.index]
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

