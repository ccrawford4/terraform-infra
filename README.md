# AWS Infrastructure using Terraform

## Overview

This Terraform module provisions a secure AWS environment with the following components:

- **VPC**: Isolated network environment
- **Bastion Host**: EC2 instance in a public subnet that serves as a secure entry point
  - Allows SSH (port 22) access only from your specified IP address
  - Provides unrestricted outbound traffic
- **Private Servers**: EC2 instances in a private subnet
  - Configurable number of instances via the `instance_count` variable
  - Accessible via SSH only through the bastion host
  - Provides unrestricted outbound traffic

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) v1.10.5 or higher
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) v2.18.5 or higher

## Setup Instructions

### 1. Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/ccrawford4/terraform-infra.git 

# Or using SSH
git clone git@github.com:ccrawford4/terraform-infra.git

cd terraform-infra
```

1A. checkout the `assignment10` branch:
```bash
git checkout assignment10
```

### 2. Configure Environment

```bash
# Create your configuration file from template
cp secrets.auto.tfvars.example secrets.auto.tfvars

# Edit the file to add your IP address
# Replace <your IP address> with your actual IP
# Replace <aws_access_key>, <aws_secret_access_key> and optionally <aws_session_token> with your actual AWS credentials
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

After deployment, you'll see output similar to:

### Connect to Ansible Manager EC2

```bash
```
./connect.sh <bastion_host_public_ip> <private_key> <manager_private_ip>

When prompted with `(yes/no/[fingerprint])?`, type `yes`. You should see:

<insert image></insert>

```bash
source .venv/bin/activate
```

cd ansible

Run the following command:
ansible-playbook -i aws_ec2.yml playbook.yml --private-key <private_key>

## Deprovisioning
To remove AWS resources when finished, execute the following command
```bash
terraform destroy
```
