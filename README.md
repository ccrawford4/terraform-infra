# AWS Infrastructure Using Terraform

## Overview

This Terraform module provisions a secure AWS environment with the following components:

- **VPC**: Isolated network environment
- **Bastion Host**: EC2 instance in a public subnet for secure access
  - Restricts SSH (port 22) access to your specified IP address
  - Allows unrestricted outbound traffic
- **Private Servers**: EC2 instances in a private subnet
  - Configurable via the `instance_count` variable
  - Accessible only through the bastion host via SSH
  - Allows unrestricted outbound traffic

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) v1.10.5 or higher
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2.18.5 or higher

## Setup Instructions

### 1. Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/ccrawford4/terraform-infra.git 

# Using SSH
git clone git@github.com:ccrawford4/terraform-infra.git
cd terraform-infra
```

Switch to the required branch:

```bash
git checkout assignment10
```

### 2. Configure Environment

```bash
# Create your configuration file from template
cp secrets.auto.tfvars.example secrets.auto.tfvars

# Edit the file to add your IP address and AWS credentials
vim secrets.auto.tfvars

# Set up AWS credentials
aws configure
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Create infrastructure
terraform apply
```

## Connecting to Ansible Manager Instance

After successful deployment, you may see an output like so:

<img width="682" alt="Screenshot 2025-03-31 at 10 42 15 PM" src="https://github.com/user-attachments/assets/2540849e-e4eb-4164-89c8-ee889328ca2b" />

Copy the required outputs and use the provided connection script:

```bash
./connect.sh <bastion_host_public_ip> <private_key> <manager_private_ip>
```

When prompted with `(yes/no/[fingerprint])?`, type `yes`.

Once connected to the manager instance:

```bash
# Activate virtual environment
source .venv/bin/activate

# Navigate to Ansible directory
cd ansible

# Run Ansible playbook
ansible-playbook -i aws_ec2.yml playbook.yml --private-key <private_key>
```

## Deprovisioning

To remove all AWS resources when finished:

```bash
terraform destroy
```
