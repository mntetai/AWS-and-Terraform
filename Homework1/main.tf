# Instances #
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
