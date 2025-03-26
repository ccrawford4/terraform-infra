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
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
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
      "sudo apt update -y",
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install -y docker-ce",
      "sudo usermod -aG docker ${var.ssh_username}",

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
