#vpc#
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

#IGW#

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gw"
  }
}

#subnet#

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "my_subnet"
  }
}



#route table#

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "my_route_table"
  }
}

resource "aws_route_table_association" "my_route_to_my_subnet" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# SECURITY GROUP #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "homework1-nginx_sg"
  vpc_id = aws_vpc.my_vpc.id

  # HTTP access from vpc 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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


resource "aws_network_interface_sg_attachment" "sg_attachment1" {
  security_group_id    = aws_security_group.nginx-sg.id
  network_interface_id = aws_network_interface.eth1.id
}

resource "aws_network_interface_sg_attachment" "sg_attachment2" {
  security_group_id    = aws_security_group.nginx-sg.id
  network_interface_id = aws_network_interface.eth0.id
}