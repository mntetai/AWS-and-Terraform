# Instances #
resource "aws_instance" "nginx1" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t3.micro"
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
    Name    = "nginx-1"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}


resource "aws_instance" "nginx2" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = "provision"
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
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("../../provision.pem")
    host        = self.public_ip
  }
  provisioner "file" {
    source      = "provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "sh /tmp/provision.sh",
    ]
  }



  tags = {
    Name    = "nginx-2"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}