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

# ------- EC2 Instance -----
variable "vpc_id" {
  type = string    
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string    
}

variable "instance_count" {
  type = number    
}

variable "admin_ip_addr" {
  type = string
}
