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

resource "aws_instance" "nginx" {
  ami           = "ami-0b5eea76982371e91"
  instance_type = "t3.micro"

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encypted              = false
    delete_on_termination = true
  }
  ebs_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    encypted              = true
    delete_on_termination = true
  }
  tags = {
    Name    = "nginx1"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}
