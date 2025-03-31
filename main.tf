module "vpc" {
  source = "./vpc"
  aws_region = var.aws_region
  vpc_cidr_block = var.vpc_cidr_block
  subnet_count = var.subnet_count
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
}

module "ec2" {
  source = "./ec2"
  aws_region = var.aws_region
  aws_access_key_id = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  aws_session_token = var.aws_session_token
  ami_name = var.ami_name
  instance_type = var.instance_type
  ssh_username = var.ssh_username
  ssh_keypair_name = var.ssh_keypair_name
  vpc_id = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
  instance_count = var.instance_count
  admin_ip_addr = var.admin_ip_addr
}

