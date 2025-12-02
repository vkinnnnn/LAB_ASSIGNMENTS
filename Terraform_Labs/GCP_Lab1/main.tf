terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Configure the Google Cloud Provider with service account credentials
provider "google" {
    project     = var.gcp_project_id
    region      = var.gcp_region
    zone        = var.gcp_zone
    credentials = file(var.service_account_path)
}

# Compute Engine VM Instance - Custom configuration for Assignment 6
resource "google_compute_instance" "assignment6_vm" {
    name         = "${var.project_name}-vm"
    machine_type = var.machine_type
    zone         = var.gcp_zone

    # Custom labels for better resource management (GCP labels must be lowercase)
    labels = {
        environment = var.environment
        owner       = var.owner
        project     = "terraform-assignment6"
        managed-by  = "terraform"
        purpose     = "learning-terraform"
        lab         = "gcp-beginner"
    }

    # Boot disk configuration with custom size and image
    boot_disk {
        initialize_params {
            image = var.boot_disk_image
            size  = var.boot_disk_size
            type  = "pd-standard"
        }
    }

    # Network interface configuration
    network_interface {
        network = "default"
        access_config {
            # Ephemeral public IP
        }
    }

    # Metadata (optional - remove SSH keys if not needed)
    # metadata = {
    #     ssh-keys = "terraform-user:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."
    # }

    # Service account with minimal permissions
    service_account {
        email  = "terafoamlab@${var.gcp_project_id}.iam.gserviceaccount.com"
        scopes = ["cloud-platform"]
    }
}

# Cloud Storage Bucket - Unique name with random suffix
resource "google_storage_bucket" "assignment6_bucket" {
    name          = "${var.project_name}-bucket-${random_id.bucket_suffix.hex}"
    location      = var.gcp_region
    force_destroy = true
    
    # Enable versioning
    versioning {
        enabled = true
    }
    
    # Lifecycle rules
    lifecycle_rule {
        condition {
            age = 30
        }
        action {
            type = "Delete"
        }
    }
    
    # Labels for organization (GCP labels must be lowercase)
    labels = {
        environment = var.environment
        owner       = var.owner
        project     = "terraform-assignment6"
        managed-by  = "terraform"
        purpose     = "storage-lab"
    }
}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
    byte_length = 4
}
