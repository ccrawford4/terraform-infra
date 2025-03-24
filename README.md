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

### 2. Configure Environment

```bash
# Create your configuration file from template
cp secrets.auto.tfvars.example secrets.auto.tfvars

# Edit the file to add your IP address
# Replace <your IP address> with your actual IP
nano secrets.auto.tfvars

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

## Connecting to Your Instances

After deployment, you'll see output similar to:

<img width="590" alt="Screenshot 2025-03-23 at 1 53 11 PM" src="https://github.com/user-attachments/assets/49707bff-77bc-405a-a6fd-f40be3079fd9" />

### Connect to Bastion Host

```bash
ssh -i ec2/ec2-keypair.pem ec2-user@<bastion_host_public_ip>
```

When prompted with `(yes/no/[fingerprint])?`, type `yes`. You should see:

<img width="747" alt="Screenshot 2025-03-23 at 1 56 50 PM" src="https://github.com/user-attachments/assets/89f219e5-0a24-41ca-8110-8da65f4ea8d2" />

Verify Docker installation:
```bash
docker -v
```

### Connect to Private Instances

From your local machine:

```bash
ssh -o "ProxyCommand=ssh -i ec2/ec2-keypair.pem ec2-user@<public_ip> -W %h:%p" -i ec2/ec2-keypair.pem ec2-user@<private_ip>
```

You should now be in a shell with the prompt `ec2-user@ip-<private_ip_address>`.

Verify Docker installation:
```bash
docker -v
```

## Deprovisioning
To remove AWS resources when finished, execute the following command
```bash
terraform destroy
```
