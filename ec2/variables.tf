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
