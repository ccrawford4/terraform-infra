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
  ssh_keypair_name = var.ssh_keypair_name
}

build {
  name = "packer"
  sources = [
    "source.amazon-ebs.amazon-linux"
  ]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker",
      "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user"
    ]
  }
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
