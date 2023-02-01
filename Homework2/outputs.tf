output "aws_lb-my_lb-dns_name" {
  value = aws_lb.my_lb.dns_name
}

output "aws_instances-nginx-public_dns" {
  value = aws_instance.nginx[*].public_dns
}


output "aws_instances-db-public_dns" {
  value = aws_instance.db[*].public_dns
}

output "aws_nat_gateway-my_nat_gw-public_ip" {
  value = aws_nat_gateway.my_nat_gw.public_ip
}