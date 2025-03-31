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
  unique_key_name = "${var.ssh_keypair_name}-${random_string.random.id}"
}

# Generate private key
resource "tls_private_key" "ec2_ssh_key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Save private key to file
resource "local_file" "private_key" {
  content = tls_private_key.ec2_ssh_key.private_key_pem
  filename = "${path.module}/${local.unique_key_name}.pem"
  file_permission = "0600"
}

# Export public key to file for Packer
resource "local_file" "public_key" {
  content = tls_private_key.ec2_ssh_key.public_key_openssh
  filename = "${path.module}/${local.unique_key_name}.pub"
}

# Export the public key to EC2
resource "aws_key_pair" "generated_key" {
  key_name = local.unique_key_name
  public_key = tls_private_key.ec2_ssh_key.public_key_openssh
}


# Create the AMI from packer
resource "null_resource" "packer" {
  triggers = {
    packer_file = sha1(file("${path.module}/build.pkr.hcl"))
    public_key = tls_private_key.ec2_ssh_key.public_key_openssh
  }
  
  provisioner "local-exec" {
    working_dir = path.module
    command     = <<EOT
packer build \
-var "aws_region=${var.aws_region}" \
-var "ami_name=${local.unique_ami_name}" \
-var "instance_type=${var.instance_type}" \
-var "ssh_username=${var.ssh_username}" \
-var "ssh_keypair_name=${local.unique_key_name}" \
-var "ssh_public_key_file=${local.unique_key_name}.pub" \
build.pkr.hcl
EOT
  }
}

# Create the bastion host security group
resource "aws_security_group" "bastion_sg" {
  name = "bastion-sg"
  vpc_id = var.vpc_id

  # Inbound traffic from admin IP address only 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.admin_ip_addr}/32"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Look up the ansible manager AMI
data "aws_ami" "manager" {
  depends_on = [null_resource.packer]
  most_recent = true
  owners = ["self"]
  
  filter {
    name = "name"
    values = ["manager-${var.ami_name}*"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

# Look up the amazon AMI
data "aws_ami" "amazon" {
  depends_on = [null_resource.packer]
  most_recent = true
  owners = ["self"]

  filter {
    name = "name"
    values = ["amazon-${var.ami_name}*"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

# Look up the ubuntu AMI
data "aws_ami" "ubuntu" {
  depends_on = [null_resource.packer]
  most_recent = true
  owners = ["self"]

  filter {
    name = "name"
    values = ["ubuntu-${var.ami_name}*"]
  }

  filter {
    name = "state"
    values = ["available"]
  }
}

# Create the Bastion Host
resource "aws_instance" "bastion" {
  associate_public_ip_address = true
  ami = data.aws_ami.amazon.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id = var.public_subnet_id
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "bastion-host"
  }
}

# Create the security group for the ansible manager private instance
resource "aws_security_group" "private_ec2_manager_sg" {
  name = "private-ec2-manager-sg"
  vpc_id = var.vpc_id
  
  # Inbound traffic from bastion host IP address only 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create private ansible amazon instance
resource "aws_instance" "private_ec2_amazon_ansible" { 
  ami = data.aws_ami.manager.id 
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.private_ec2_manager_sg.id]
  subnet_id = var.private_subnet_id

  tags = {
    Name = "private-ec2-amazon-manager",
  }
}

# Create the security group for the private worker instances 
resource "aws_security_group" "private_ec2_sg" {
  name = "private-ec2-sg"
  vpc_id = var.vpc_id
  
  # Inbound traffic from bastion host IP address only 
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.private_ec2_amazon_ansible.private_ip}/32"]
  }
  
  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create three private amazon instances
resource "aws_instance" "private_ec2_amazon" {
  count = 3 
  ami = data.aws_ami.amazon.id 
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  subnet_id = var.private_subnet_id

  tags = {
    Name = "private-ec2-amazon-${count.index + 1}",
    OS = "amazon"
  }
}

# Create three private ubuntu instances
resource "aws_instance" "private_ec2_ubuntu" {
  count = 3 
  ami = data.aws_ami.ubuntu.id 
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]
  subnet_id = var.private_subnet_id

  tags = {
    Name = "private-ec2-ubuntu-${count.index + 1}",
    OS = "ubuntu"
  }
}
