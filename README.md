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

# Edit the file to add your IP address
vi secrets.auto.tfvars

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

After successful deployment, use the provided connection script:

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
Note: use `--forks=1` if running a smaller machine with limited CPU
ansible-playbook -i aws_ec2.yml playbook.yml --private-key <private_key> --forks=1
```

## Deprovisioning

To remove all AWS resources when finished:

```bash
terraform destroy
```
