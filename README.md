# AWS Infrastructure using Terraform

## About
This Terraform module provisions a secure AWS environment with the following components:
* **VPC**
* **Bastion Host (EC2 Instance)**
  * Within the VPC in public subnet
  * SSH (22) ingress traffic from client IP address only
  * Unrestricted egress traffic
* **Private Servers (EC2 Instance)**
  * Within VPC in private subnet
  * Configure number of instances created using the `instance_count` variable
  * SSH (22) ingress traffic from bastion host IP address only
  * Unrestricted egress traffic
  
## Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/install) >= v1.10.5
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) >= 2.18.5

## Installation

1. Clone the repository
   ```bash
   # Using HTTPS
   git clone https://github.com/ccrawford4/terraform-infra.git 
   
   # Or using SSH
   git clone git@github.com:ccrawford4/terraform-infra.git
   ```

2. Navigate to the repository directory
   ```bash
   cd terraform-infra
   ```

## Environment Configuration

1. Create your `secrets.auto.tfvars` file
   ```bash
   cp secrets.auto.tfvars.example secrets.auto.tfvars
   ```

2. Edit the `secrets.auto.tfvars` file to include your host machines IP address:
   ```terraform
   admin_ip_addr = "<your IP address>" 
   ```

3. Configure AWS CLI with your AWS credentials
   ```bash
   aws configure
   ```

## Infrastructure Deployment
1. Initialize the backend
```bash
terraform init
```
2. Run terraform plan
```bash
terraform plan
```
3. Run terraform apply
```bash
terraform apply
```

## Testing
From the `terraform apply` step you should see an output like so:
<img width="590" alt="Screenshot 2025-03-23 at 1 53 11 PM" src="https://github.com/user-attachments/assets/49707bff-77bc-405a-a6fd-f40be3079fd9" />
1. Copy the `bastion_host_public_ip` output and run the following
```bash
ssh -i ec2/ec2-keypair.pem ec2-user@<bastion host public ip>
```
You will be asked if you want to continue connecting `(yes/no/[fingerpring])?` type `yes` and then you should see this output:
<img width="747" alt="Screenshot 2025-03-23 at 1 56 50 PM" src="https://github.com/user-attachments/assets/89f219e5-0a24-41ca-8110-8da65f4ea8d2" />
`
2. Test that docker has been installed
```bash
docker -v
```
3. Exit the terminal and return to your host machine shell. Now you can test using your bastion host as a proxy to ssh into the private ec2. Copy one of the private IP addresses from the `terrafrom apply` output and then run the following
```bash
ssh -o "ProxyCommand=ssh -i ec2/ec2-keypair.pem ec2-user@<public ip> -W %h:%p" -i ec2/ec2-keypair.pem ec2-user@<private ip>
```
You should now be in a shell that has the prompt `ec2-user@ip-<private ip address>`
4. Run `docker -v` to confirm that docker is also installed on the private ec2 instances
