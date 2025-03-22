variable "aws_region" {
  type = string
}

# ------- Packer ---------
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
