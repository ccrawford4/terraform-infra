output "bastion_host_public_ip" {
  value = module.ec2.bastion_host_public_ip
}

output "manager_private_ip" {
  value = module.ec2.manager_private_ip
}

output "private_key" {
  value = module.ec2.private_key
}
