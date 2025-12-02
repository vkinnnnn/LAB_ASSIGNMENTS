variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
  default     = "rich-atom-476217-j9"
}

variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-west1"
}

variable "gcp_zone" {
  description = "GCP zone for resources"
  type        = string
  default     = "us-west1-a"
}

variable "machine_type" {
  description = "GCP machine type for VM instance"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "assignment6-gcp-terraform"
}

variable "environment" {
  description = "Environment label"
  type        = string
  default     = "development"
}

variable "owner" {
  description = "Owner label"
  type        = string
  default     = "assignment6-student"
}

variable "service_account_path" {
  description = "Path to service account JSON file"
  type        = string
  default     = "./service-account.json"
}

