output "aws_instance_public_dns-1" {
  value = aws_instance.nginx1.public_dns
}

output "aws_instance_public_dns-2" {
  value = aws_instance.nginx2.public_dns
}