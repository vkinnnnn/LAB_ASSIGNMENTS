# Terraform Labs (Assignment 6)

## Overview

This folder contains two Terraform labs that provision minimal but realistic cloud infrastructure on **AWS** and **GCP**. Each lab is selfcontained, parameterized with variables, and saves Terraform outputs and logs to an outputs/ folder for easy review.

## Structure

- AWS_Lab1/ – AWS networking + EC2 lab
- GCP_Lab1/ – GCP Compute Engine + Cloud Storage lab
- un-labs.ps1 – Optional helper script (local use only, do **not** commit real keys inside it)

## AWS Lab 1 (AWS_Lab1)

**Builds:**
- VPC 10.1.0.0/16 with DNS support
- Public subnet 10.1.1.0/24 + internet gateway + route table
- Amazon Linux 2 EC2 instance (	3.micro) tagged for project/owner

**Run:**
`powershell
cd Terraform_Labs/AWS_Lab1
# Set AWS credentials in your shell (example)
AKIARE2G6Z2454YUTVEW="YOUR_KEY_ID"
cDUERqSuzVMa2+Bkl2RTjved7FiGY+aBJwfWtgDT="YOUR_SECRET"
us-west-2="us-west-2"

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve
`

Outputs and logs are written to AWS_Lab1/outputs/.

More details: see AWS_Lab1/README.md and (optionally) IMPLEMENTATION.md if present.

## GCP Lab 1 (GCP_Lab1)

**Builds:**
- Compute Engine VM (e2-micro, Debian 12, 20GB boot disk)
- Cloud Storage bucket with versioning + 30day lifecycle rule
- Random ID resource to ensure unique bucket names

**Run:**
`powershell
cd Terraform_Labs/GCP_Lab1

# Ensure gcloud is authenticated and required APIs are enabled
# (see GCP_Lab1/README.md for exact commands)

terraform init
terraform plan -out=tfplan
terraform apply -auto-approve
`

Outputs and logs are written to GCP_Lab1/outputs/.

More details: see GCP_Lab1/README.md.

## Files You SHOULD NOT Commit

When pushing this folder to GitHub, make sure the following never get committed:

- Terraform state and plan files:
  - **/terraform.tfstate*
  - **/tfplan*
  - **/.terraform/
- Credentials:
  - Any service-account.json or other secret key files
  - Any script that contains real access keys (e.g. a customized un-labs.ps1)
- Local .tfvars or other files with secrets

Use a .gitignore similar to:
`gitignore
**/.terraform/
**/.terraform.lock.hcl
**/terraform.tfstate*
**/tfplan*
**/*.tfvars*
**/outputs/
**/service-account.json
`

## Cleanup

Always destroy resources when you are done to avoid costs:

`powershell
# AWS
cd Terraform_Labs/AWS_Lab1
terraform destroy -auto-approve

# GCP
cd Terraform_Labs/GCP_Lab1
terraform destroy -auto-approve
`

## Notes

- These labs are customized versions of the original Terraform labs from the MLOps course repo ([MLOps Terraform_Labs](https://github.com/raminmohammadi/MLOps/tree/main/Labs/Terraform_Labs)).
- The goal is to demonstrate clean, parameterized IaC for both clouds while keeping credentials out of version control.
