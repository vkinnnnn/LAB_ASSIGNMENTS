# GCP Terraform Lab (Assignment 6)

## What This Lab Builds
- Compute Engine VM (`e2-micro`, Debian 12, 20 GB boot disk)
- Cloud Storage bucket with versioning + 30‑day lifecycle rule
- Random ID resource for globally unique bucket names
- Service account authentication from local `service-account.json` (ignored by Git)

## Prerequisites
1. Terraform >= 1.0
2. Google Cloud SDK (`gcloud`) authenticated to project `rich-atom-476217-j9`
3. Service account key saved as `service-account.json` with Compute + Storage roles
4. Required APIs enabled:
   ```powershell
   gcloud services enable compute.googleapis.com storage-component.googleapis.com `
       --project=rich-atom-476217-j9
   ```

## Deploy
```powershell
cd Terraform_Labs/GCP_Lab1
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve
```
Outputs are persisted in `outputs/` (text + JSON) for auditing.

## Key Variables (`variables.tf`)
| Variable               | Default                 | Purpose                |
|------------------------|-------------------------|------------------------|
| `gcp_project_id`       | `rich-atom-476217-j9`   | Target project         |
| `gcp_region`           | `us-west1`              | Regional resources     |
| `gcp_zone`             | `us-west1-a`            | VM zone                |
| `machine_type`         | `e2-micro`              | VM flavor              |
| `service_account_path` | `./service-account.json`| Credential location    |

## Cleanup
```powershell
terraform destroy -auto-approve
```

## Notes
- Bucket name format: `${var.project_name}-bucket-${random_id.bucket_suffix}`.
- Keep `service-account.json`, `terraform.tfstate`, and `tfplan` out of Git.
- See `IMPLEMENTATION.md` and `outputs/` for detailed run logs.
