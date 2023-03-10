#vpc#
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr_range
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

resource "aws_subnet" "public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "public_subnet${count.index}"
  }
}



resource "aws_subnet" "private_subnet" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private_subnet${count.index}"
  }
}



#public ip allocations#

resource "aws_eip" "my_nat_public_ip" {
  vpc = true
}

#NAT GW#

resource "aws_nat_gateway" "my_nat_gw" {
  allocation_id = aws_eip.my_nat_public_ip.id
  subnet_id     = aws_subnet.public_subnet[0].id

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
    cidr_block = var.internet_cidr_range
    gateway_id = aws_internet_gateway.my_gw.id
  }
  tags = {
    Name = "vpc_route_table_public"
  }
}

resource "aws_route_table" "vpc_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = var.internet_cidr_range
    nat_gateway_id = aws_nat_gateway.my_nat_gw.id
  }

  tags = {
    Name = "vpc_route_table_private"
  }
}

resource "aws_route_table_association" "route_public_subnet" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.vpc_route_table_public.id
}

resource "aws_route_table_association" "route_private_subnet" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.private_subnet[count.index].id
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
    cidr_blocks = [var.vpc_cidr_range]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.internet_cidr_range]
  }

  #allow ping form vpc#

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_range]
  }
  # outbound allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet_cidr_range]
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
    cidr_blocks = [var.internet_cidr_range]
  }
  #allow ping form vpc#
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_range]
  }

  # outbound allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet_cidr_range]
  }
  tags = {
    Name  = "DB security group"
    Owner = "Etai Tavor"
  }
}

resource "aws_security_group" "elb-sg" {
  name   = "homework2-elb_sg"
  vpc_id = aws_vpc.my_vpc.id
  # HTTP access from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.internet_cidr_range]
  }
  # outbound allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet_cidr_range]
  }
  tags = {
    Name  = "ELB security group"
    Owner = "Etai Tavor"
  }
}

resource "aws_lb" "my_lb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb-sg.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]

  enable_deletion_protection = false

  tags = {
    Environment = "test"
    Name        = "my-elb"
  }
}

resource "aws_lb_target_group" "my_lb" {
  name     = "alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path                = "/"
    port                = 80
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 20
    matcher             = "200"
  }
}

resource "aws_lb_listener" "my_lb" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_lb.arn
  }

  tags = {
    Name  = "lb listener"
    Owner = "Etai Tavor"
  }
}

resource "aws_lb_target_group_attachment" "my_lb" {
  count            = var.nginx_instances_count
  target_group_arn = aws_lb_target_group.my_lb.arn
  target_id        = aws_instance.nginx[count.index].id
  port             = 80
}
