output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "public_subnets" {
  value = [for subnet in aws_subnet.public_subnet : subnet.id]
}

output "private_subnets" {
  value = [for subnet in aws_subnet.private_subnet : subnet.id]
}

output "private_subnet_count" {
    value = var.private_subnet_count
}

output "my_nat_gw" {
    value = aws_nat_gateway.my_nat_gw
}