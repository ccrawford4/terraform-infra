output "ec2_dns_endpoint" {
  value = aws_instance.bastion.public_dns
}
