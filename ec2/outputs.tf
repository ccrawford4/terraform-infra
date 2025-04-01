output "bastion_host_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "manager_private_ip" {
  value = aws_instance.private_ec2_amazon_ansible.private_ip
}

output "private_key" {
  value = "${local.unique_key_name}.pem"
}
