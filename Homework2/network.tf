#vpc#
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = var.enable_dns_hostnames
}

#IGW#

resource "aws_internet_gateway" "my_gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_gw1"
  }
}

#subnet#

resource "aws_subnet" "nginx_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "nginx_subnet1"
  }
}

resource "aws_subnet" "nginx_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "nginx_subnet2"
  }
}

resource "aws_subnet" "db_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "db_subnet1"
  }
}

resource "aws_subnet" "db_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "db_subnet2"
  }
}

#public ip allocations#

resource "aws_eip" "my_nat_public_ip" {
  vpc = true
}

#NAT GW#

resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.my_nat_public_ip.id
  subnet_id     = aws_subnet.nginx_subnet1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.my_gw]
}

#route tables#

resource "aws_route_table" "vpc_route_table_public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "vpc_route_table_public"
  }
}

resource "aws_route_table" "vpc_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_gw.id
  }

  tags = {
    Name = "vpc_route_table_private"
  }
}

resource "aws_route_table_association" "route_nginx_subnet1" {
  subnet_id      = aws_subnet.nginx_subnet1.id
  route_table_id = aws_route_table.vpc_route_table_public.id
}

resource "aws_route_table_association" "route_db_subnet1" {
  subnet_id      = aws_subnet.db_subnet1.id
  route_table_id = aws_route_table.vpc_route_table_private.id
}

resource "aws_route_table_association" "route_nginx_subnet2" {
  subnet_id      = aws_subnet.nginx_subnet2.id
  route_table_id = aws_route_table.vpc_route_table_public.id
}

resource "aws_route_table_association" "route_db_subnet2" {
  subnet_id      = aws_subnet.db_subnet2.id
  route_table_id = aws_route_table.vpc_route_table_private.id
}


# SECURITY GROUPS #
# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "homework2-nginx_sg"
  vpc_id = aws_vpc.my_vpc.id
  # HTTP access from elb
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

  #allow ping form vpc#

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
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

# DB security group 
resource "aws_security_group" "db-sg" {
  name   = "homework2-db_sg"
  vpc_id = aws_vpc.my_vpc.id

  # SSH access from vpc 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  #allow ping form vpc#
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # outbound allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "DB security group"
    Owner = "Etai Tavor"
  }
}

resource "aws_elb" "my_elb" {
  name     = "my-elb"
  internal = false
  #load_balancer_type = "application"
  security_groups = [aws_security_group.nginx-sg.id]
  subnets         = [aws_subnet.nginx_subnet1.id, aws_subnet.nginx_subnet2.id]

  #enable_deletion_protection = false

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    target              = "HTTP:80/"
    interval            = 60
  }

  instances                 = [aws_instance.nginx1.id, aws_instance.nginx2.id]
  cross_zone_load_balancing = true
  idle_timeout              = 400
  #connection_draining         = true
  #connection_draining_timeout = 400
  tags = {
    Environment = "test"
    Name        = "my-elb"
  }
}