output "vm_instance_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.assignment6_vm.name
}

output "vm_instance_id" {
  description = "ID of the VM instance"
  value       = google_compute_instance.assignment6_vm.id
}

output "vm_instance_zone" {
  description = "Zone of the VM instance"
  value       = google_compute_instance.assignment6_vm.zone
}

output "vm_instance_machine_type" {
  description = "Machine type of the VM instance"
  value       = google_compute_instance.assignment6_vm.machine_type
}

output "vm_instance_network_ip" {
  description = "Internal IP address of the VM instance"
  value       = google_compute_instance.assignment6_vm.network_interface[0].network_ip
}

output "vm_instance_external_ip" {
  description = "External IP address of the VM instance"
  value       = google_compute_instance.assignment6_vm.network_interface[0].access_config[0].nat_ip
}

output "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.assignment6_bucket.name
}

output "storage_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.assignment6_bucket.url
}

output "storage_bucket_location" {
  description = "Location of the Cloud Storage bucket"
  value       = google_storage_bucket.assignment6_bucket.location
}

