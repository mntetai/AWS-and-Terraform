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
  tags = {
    Name = "vpc_route_table_public"
  }
}

resource "aws_route" "route_public" {
  route_table_id         = aws_route_table.vpc_route_table_public.id
  destination_cidr_block = var.internet_cidr_range
  gateway_id             = aws_internet_gateway.my_gw.id
  depends_on             = [aws_route_table.vpc_route_table_public]
}

resource "aws_route_table" "vpc_route_table_private" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "vpc_route_table_private"
  }
}

resource "aws_route" "route_private" {
  route_table_id         = aws_route_table.vpc_route_table_private.id
  destination_cidr_block = var.internet_cidr_range
  nat_gateway_id         = aws_nat_gateway.my_nat_gw.id
  depends_on             = [aws_route_table.vpc_route_table_private]
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

