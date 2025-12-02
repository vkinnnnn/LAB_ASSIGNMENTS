# Run Both Terraform Labs and Save Outputs
# This script runs AWS and GCP labs and saves all outputs

$ErrorActionPreference = "Continue"

# Import AWS credentials configuration (set these in your shell beforehand)
Write-Host "Using AWS credentials from current PowerShell session..." -ForegroundColor Green
if (-not $env:AWS_ACCESS_KEY_ID -or -not $env:AWS_SECRET_ACCESS_KEY) {
    Write-Warning "AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY are not set. Set them before running this script."
}
if (-not $env:AWS_DEFAULT_REGION) {
    $env:AWS_DEFAULT_REGION = "us-west-2"
}
Write-Host "AWS Region: $env:AWS_DEFAULT_REGION" -ForegroundColor Gray

# Create output directories
Write-Host "`nCreating output directories..." -ForegroundColor Green
New-Item -ItemType Directory -Force -Path "Terraform_Labs\AWS_Lab1\outputs" | Out-Null
New-Item -ItemType Directory -Force -Path "Terraform_Labs\GCP_Lab1\outputs" | Out-Null

# ===== AWS LAB =====
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "=== RUNNING AWS LAB ===" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location "Terraform_Labs\AWS_Lab1"

try {
    Write-Host "[1/4] Initializing Terraform..." -ForegroundColor Yellow
    terraform init 2>&1 | Tee-Object -FilePath "outputs\terraform-init.txt"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed"
    }
    
    Write-Host "`n[2/4] Planning AWS resources..." -ForegroundColor Yellow
    terraform plan -out=tfplan 2>&1 | Tee-Object -FilePath "outputs\terraform-plan.txt"
    
    Write-Host "`n[3/4] Applying AWS configuration (this creates real resources)..." -ForegroundColor Yellow
    terraform apply -auto-approve 2>&1 | Tee-Object -FilePath "outputs\terraform-apply.txt"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform apply failed"
    }
    
    Write-Host "`n[4/4] Saving AWS outputs..." -ForegroundColor Yellow
    terraform output > outputs\terraform-outputs.txt 2>&1
    terraform output -json > outputs\terraform-outputs.json 2>&1
    terraform show > outputs\terraform-show.txt 2>&1
    
    Write-Host "`n✓ AWS Lab completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "`n✗ AWS Lab failed: $_" -ForegroundColor Red
    Write-Host "Check outputs\terraform-apply.txt for details" -ForegroundColor Yellow
}

# ===== GCP LAB =====
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "=== RUNNING GCP LAB ===" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Set-Location "..\GCP_Lab1"

try {
    Write-Host "[1/4] Initializing Terraform..." -ForegroundColor Yellow
    terraform init 2>&1 | Tee-Object -FilePath "outputs\terraform-init.txt"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed"
    }
    
    Write-Host "`n[2/4] Planning GCP resources..." -ForegroundColor Yellow
    terraform plan -out=tfplan 2>&1 | Tee-Object -FilePath "outputs\terraform-plan.txt"
    
    Write-Host "`n[3/4] Applying GCP configuration (this creates real resources)..." -ForegroundColor Yellow
    terraform apply -auto-approve 2>&1 | Tee-Object -FilePath "outputs\terraform-apply.txt"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform apply failed"
    }
    
    Write-Host "`n[4/4] Saving GCP outputs..." -ForegroundColor Yellow
    terraform output > outputs\terraform-outputs.txt 2>&1
    terraform output -json > outputs\terraform-outputs.json 2>&1
    terraform show > outputs\terraform-show.txt 2>&1
    
    Write-Host "`n✓ GCP Lab completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "`n✗ GCP Lab failed: $_" -ForegroundColor Red
    Write-Host "Check outputs\terraform-apply.txt for details" -ForegroundColor Yellow
}

# Return to original directory
Set-Location ..\..

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "=== ALL LABS COMPLETED ===" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
Write-Host "Output files saved in:" -ForegroundColor Cyan
Write-Host "  - Terraform_Labs\AWS_Lab1\outputs\" -ForegroundColor Yellow
Write-Host "  - Terraform_Labs\GCP_Lab1\outputs\" -ForegroundColor Yellow

