provider "aws" {
  region = var.aws_region
}

# Generate private key
resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
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
-var "ami_name=${var.ami_name}" \
-var "instance_type=${var.instance_type}" \
-var "ssh_username=${var.ssh_username}" \
-var "ssh_keypair_name=${var.ssh_keypair_name}" \
build.pkr.hcl
EOT
  }
}
