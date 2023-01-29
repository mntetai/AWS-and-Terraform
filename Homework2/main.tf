# Instances #
resource "aws_instance" "nginx1" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.nginx_subnet1.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[0]
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
  sudo echo "<html><head><title>Grandpa's Whiskey1</title></head><body>Welcome to Grandpa's Whiskey</body></html>" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name    = "nginx-1"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}


resource "aws_instance" "nginx2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.nginx_subnet2.id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[1]
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
  sudo echo "<html><head><title>Grandpa's Whiskey2</title></head><body>Welcome to Grandpa's Whiskey</body></html>" > /usr/share/nginx/html/index.html
EOF 


  tags = {
    Name    = "nginx-2"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}

resource "aws_instance" "db1" {
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.db_subnet1.id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[0]
  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  user_data = <<EOF
  #!/bin/bash
  cd ~
  echo "this is a db server1" >> db.txt
EOF 
  tags = {
    Name    = "db-1"
    Owner   = "Etai Tavor"
    Purpose = "db"
  }
}

resource "aws_instance" "db2" {
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = aws_subnet.db_subnet2.id
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  availability_zone      = data.aws_availability_zones.available.names[1]
  instance_type          = "t3.micro"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }

  user_data = <<EOF
  #!/bin/bash
  cd ~
  echo "this is a db server2" >> db.txt
EOF 
  tags = {
    Name    = "db-2"
    Owner   = "Etai Tavor"
    Purpose = "db"
  }
}