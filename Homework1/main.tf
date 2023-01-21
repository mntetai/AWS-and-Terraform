terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

# SECURITY GROUP #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name = "homework1-nginx_sg"

  # HTTP access from vpc 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "Nginx security group"
    Owner = "Etai Tavor"
  }
}

resource "aws_instance" "nginx" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t3.micro"
  count                  = var.instance_count
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = false
    delete_on_termination = true
  }
  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_size           = "10"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }

  user_data = <<EOF
  #!/bin/bash
  sudo amazon-linux-extras install nginx1
  sudo service nginx start
  sudo rm /usr/share/nginx/html/index.html
  sudo echo "Welcome to Grandpa's Whiskey" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name    = "nginx-${count.index}"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}


output "aws_instance_public_dns-1" {
  value = aws_instance.nginx[0].public_dns
}

output "aws_instance_public_dns-2" {
  value = aws_instance.nginx[1].public_dns
}
