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

# ------------ EC2 + Packer --------------
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

variable "instance_count" {
  type = string
}

variable "admin_ip_addr" {
  type = string
}

# ------------ VPC -------------------
variable "vpc_cidr_block" {
  type = string    
}

variable "subnet_count" {
  type = map(number) 
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
}
