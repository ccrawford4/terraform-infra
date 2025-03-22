provider "aws" {
  region = var.aws_region
}

resource "random_string" "random" {
  length = 8
  special = false 
  upper = false
}

locals {
  unique_ami_name = "${var.ami_name}-${random_string.random.id}"
}

# Generate private key
resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Save private key to file
resource "local_file" "private_key" {
  content = tls_private_key.ec2_ssh_key.private_key_pem
  filename = "${path.module}/${var.ssh_keypair_name}.pem"
  file_permission = "0600"
}

# Export public key to file for Packer
resource "local_file" "public_key" {
  content = tls_private_key.ec2_ssh_key.public_key_openssh
  filename = "${path.module}/${var.ssh_keypair_name}.pub"
}

# Create the AMI from packer
resource "null_resource" "packer" {
  triggers = {
    packer_file = sha1(file("${path.module}/build.pkr.hcl"))
  }
  
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
packer build \
-var "aws_region=${var.aws_region}" \
-var "ami_name=${local.unique_ami_name}" \
-var "instance_type=${var.instance_type}" \
-var "ssh_username=${var.ssh_username}" \
-var "ssh_keypair_name=${var.ssh_keypair_name}" \
-var "ssh_public_key_file=${var.ssh_keypair_name}.pub" \
build.pkr.hcl
EOT
  }
}
