output "aws_lb-my_lb-dns_name" {
  value = aws_lb.my_lb.dns_name
}

output "aws_instance-nginx2-public_dns" {
  value = aws_instance.nginx[1].public_dns
}

output "aws_instance-nginx1-public_dns" {
  value = aws_instance.nginx[0].public_dns
}

output "aws_instance-db2-public_dns" {
  value = aws_instance.db[1].public_dns
}

output "aws_instance-db1-public_dns" {
  value = aws_instance.db[0].public_dns
}

output "aws_nat_gateway-my_nat_gw-public_ip" {
  value = aws_nat_gateway.my_nat_gw.public_ip
}