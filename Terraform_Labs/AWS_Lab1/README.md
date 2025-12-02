# AWS Terraform Lab (Assignment 6)

## What This Lab Builds
- Custom VPC (`10.1.0.0/16`) with DNS support
- Public subnet, internet gateway, and route table
- Amazon Linux 2 EC2 instance (`t3.micro`) with project tagging
- Terraform outputs saved to `outputs/` (text + JSON)

## Prerequisites
1. Terraform >= 1.0 (local copy in `../terraform-bin`)
2. AWS CLI configured with IAM credentials that can create VPC + EC2 resources
3. Export credentials before running:
   ```powershell
   $env:AWS_ACCESS_KEY_ID="YOUR_KEY_ID"
   $env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET"
   $env:AWS_DEFAULT_REGION="us-west-2"
   ```

## Deploy
```powershell
cd Terraform_Labs/AWS_Lab1
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve
```

## Key Variables (`variables.tf`)
| Variable        | Default       | Purpose               |
|-----------------|---------------|-----------------------|
| `aws_region`    | `us-west-2`   | Deployment region     |
| `instance_type` | `t3.micro`    | EC2 size              |
| `vpc_cidr`      | `10.1.0.0/16` | VPC CIDR block        |
| `subnet_cidr`   | `10.1.1.0/24` | Public subnet CIDR    |

## Cleanup
```powershell
terraform destroy -auto-approve
```

## Notes
- The latest Amazon Linux 2 AMI is resolved via `data "aws_ami"`.
- Keep `terraform.tfstate`, `tfplan`, and credentials out of Git.
- See `IMPLEMENTATION.md` and `outputs/` for execution details.
