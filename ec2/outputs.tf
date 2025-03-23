output "ec2_dns_endpoint" {
  value = aws_instance.bastion.public_dns
}

output "ec2_private_ip" {
  value = aws_instance.private_ec2[*].private_ip
}
