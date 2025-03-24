output "bastion_host_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.private_ec2[*].private_ip
}

output "private_key" {
  value = '${local.unique_key_name}.pem"
}
