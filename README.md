# Master Terraform with This EC2 Deployment Guide (EC2 With Provisioners)

## Introduction
This Terraform project is designed to simplify the deployment of an EC2 instance on AWS. By leveraging Infrastructure as Code (IaC), we ensure that the provisioning process is efficient, secure, and repeatable. This guide will help you understand how to use this template and learn key Terraform concepts along the way.

## What This Project Does
With this Terraform template, you can:
- Deploy an **EC2 instance** in the **us-east-1** region.
- Configure **security groups** to allow SSH (`22`), HTTP (`80`), and HTTPS (`443`) traffic.
- Attach an **8GB encrypted EBS volume** (`gp3` type) to the instance.
- Set up an **Ubuntu 22.04** AMI (`ami-04b4f1a9cf54c11d0`).
- Install and configure **Nginx** as a web server.
- Use an **SSH key pair** (`useast.pem`) for secure access.
- Optionally enable **CloudWatch monitoring**.

## Why Use This?
### Benefits:
- **Learning Terraform**: If you are new to Terraform, this project is an excellent way to get hands-on experience.
- **Infrastructure as Code (IaC)**: Automates deployment, reduces manual errors, and provides consistency.
- **Scalability**: Modify instance count and type easily.
- **Security Best Practices**: Configurable security rules to restrict access.

## How to Use
### Prerequisites:
- Install **Terraform**.
- Configure your **AWS credentials**.

### Steps:
1. **Clone the Repository**:
   ```sh
   git clone <repository-url>
   cd <repository-folder>
   ```
2. **Initialize Terraform**:
   ```sh
   terraform init
   ```
3. **Review and Plan Deployment**:
   ```sh
   terraform plan
   ```
4. **Apply Configuration**:
   ```sh
   terraform apply -auto-approve
   ```
5. **Access Your EC2 Instance**:
   ```sh
   ssh -i "C:/Users/sohel mohammed/useast.pem" ubuntu@<public-ip>
   ```

## Cleanup
When you no longer need the instance, destroy it using:
```sh
terraform destroy -auto-approve
```

## Key Takeaways
- Terraform makes cloud infrastructure deployment **fast and reliable**.
- This project is a **great starting point** for anyone looking to understand AWS and Terraform.
- **Experiment, tweak, and learn**—this is how you master DevOps automation!

---
Start building your Terraform skills today and create AWS infrastructure with confidence!

