packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = var.ami_name
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      architecture = "arm64",
      name         = "*amzn2-ami-hvm-*"
    }
    most_recent = true
    owners = ["amazon"]
  }
  ssh_username = var.ssh_username
}

build {
  name = "packer"
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "file" {
    source = var.ssh_public_key_file
    destination = "/tmp/imported_key.pub"
  }

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker",
      "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user",

      # Add public key to authorized keys
      "cat /tmp/imported_key.pub >> ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
      "rm /tmp/imported_key.pub"
    ]
  }
}

variable "aws_region" {
  type = string
}

variable "ami_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ssh_username" {
  type = string
}

variable "ssh_keypair_name" {
  type = string
}

variable "ssh_public_key_file" {
  type = string
}
