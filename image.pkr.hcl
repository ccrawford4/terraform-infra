packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "amazon-linux" {
  ami_name      = "oneflow-dev-custom-ami"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      virtuliaziation-type = "hvm",
      architecture = "arm64",
      name = "*amzn2-ami-hvn-*",
    } 
  }
  ssh_username = "ec2-user"
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

