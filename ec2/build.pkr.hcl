packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "manager" {
  ami_name = "manager-${var.ami_name}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami = "ami-0e3faa5e960844571"
  ssh_username = "ec2-user"
}

source "amazon-ebs" "amazon" {
  ami_name      = "amazon-${var.ami_name}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami = "ami-0e3faa5e960844571"
  ssh_username = "ec2-user"
}

source "amazon-ebs" "ubuntu" {
  ami_name = "ubuntu-${var.ami_name}"
  instance_type = var.instance_type
  region        = var.aws_region
  source_ami = "ami-0c4e709339fa8521a" 
  ssh_username = "ubuntu"
}

build {
  name = "packer"
  sources = [
    "source.amazon-ebs.amazon",
    "source.amazon-ebs.ubuntu",
    "source.amazon-ebs.manager"
  ]

   provisioner "file" {
    source = var.ssh_public_key_file
    destination = "/tmp/imported_key.pub"
  }

  provisioner "shell" {
    only = ["amazon-ebs.amazon"]
    inline = [
      # Install and set up docker
      "sudo amazon-linux-extras install docker",
      "sudo yum install -y docker",
      "sudo usermod -a -G docker ec2-user",

      # Add public key to authorized keys
      "cat /tmp/imported_key.pub >> ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
      "rm /tmp/imported_key.pub"
   ]
  }

  provisioner "shell" {
    only = ["amazon-ebs.ubuntu"]
    inline = [
      "sudo apt update -y",
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=arm64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt update -y",
      "sudo apt install -y docker-ce",
      "sudo usermod -aG docker ubuntu",

      # Install ansible
      "sudo apt install ansible -y",
      "sudo apt-get install -y python3-pip",

       # Add public key to authorized keys
      "cat /tmp/imported_key.pub >> ~/.ssh/authorized_keys",
      "chmod 700 ~/.ssh",
      "rm /tmp/imported_key.pub"
    ]
  }

  provisioner "shell" {
    only = ["amazon-ebs.manager"]
    inline = [
        # Install python3.8
        "sudo amazon-linux-extras install python3.8 -y",

        # Create a virtual env and activate it
        "python3.8 -m venv .venv",
        "source .venv/bin/activate",

        # Install ansible and other dependencies
        "pip install ansible==2.9.23",
        "pip install boto3 botocore",
        "ansible-galaxy collection install amazon.aws",

        # Set AWS credentials
        "mkdir -p ~/.aws",
        "echo '[default]' > ~/.aws/credentials",
        "echo 'aws_access_key_id=${var.aws_access_key_id}' >> ~/.aws/credentials",
        "echo 'aws_secret_access_key=${var.aws_secret_access_key}' >> ~/.aws/credentials",
        "echo 'aws_session_token=${var.aws_session_token}' >> ~/.aws/credentials",

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

variable "aws_access_key_id" {
  type = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type = string
  sensitive = true
}

variable "aws_session_token" {
  type = string
  sensitive = true
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
