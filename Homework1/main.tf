#ENIS#

resource "aws_network_interface" "eth0" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["10.0.0.10"]
  tags = {
    Name = "primary_network_interface eth0"
  }
}

resource "aws_network_interface" "eth1" {
  subnet_id   = aws_subnet.my_subnet.id
  private_ips = ["10.0.0.11"]
  tags = {
    Name = "primary_network_interface eth1"
  }
}
# Instances #
resource "aws_instance" "nginx1" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.micro"

  network_interface {
    network_interface_id = aws_network_interface.eth0.id
    device_index         = 0
  }
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
  sudo echo "<html><head><title>Grandpa's Whiskey</title></head><body>Welcome to Grandpa's Whiskey</body></html>" > /usr/share/nginx/html/index.html
EOF

  tags = {
    Name    = "nginx-1"
    Owner   = "Etai Tavor"
    Purpose = "whiskey"
  }
}


resource "aws_instance" "nginx2" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.micro"
  key_name      = "provision"

  network_interface {
    network_interface_id = aws_network_interface.eth1.id
    device_index         = 0
  }

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