variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-west-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "assignment6-terraform"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "development"
}

variable "owner" {
  description = "Owner tag"
  type        = string
  default     = "assignment6-student"
}

