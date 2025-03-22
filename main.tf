module "ec2" {
  source = "./ec2"
  aws_region = var.aws_region
  ami_name = var.ami_name
  instance_type = var.instance_type
  ssh_username = var.ssh_username
  ssh_keypair_name = var.ssh_keypair_name
}
