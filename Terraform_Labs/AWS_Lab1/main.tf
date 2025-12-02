provider "aws" {
    region = var.aws_region
}

# VPC Resource - Custom CIDR block for Assignment 6
resource "aws_vpc" "assignment6_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true
    
    tags = {
        Name        = "${var.project_name}-vpc"
        Environment = var.environment
        Owner       = var.owner
        Project     = "Terraform-Assignment6"
        ManagedBy   = "Terraform"
    }
}

# Internet Gateway for VPC
resource "aws_internet_gateway" "assignment6_igw" {
    vpc_id = aws_vpc.assignment6_vpc.id
    
    tags = {
        Name        = "${var.project_name}-igw"
        Environment = var.environment
        Owner       = var.owner
        Project     = "Terraform-Assignment6"
        ManagedBy   = "Terraform"
    }
}

# Subnet Resource - Custom CIDR block (Public subnet)
resource "aws_subnet" "assignment6_subnet" {
    vpc_id                  = aws_vpc.assignment6_vpc.id
    cidr_block              = var.subnet_cidr
    availability_zone       = "${var.aws_region}a"
    map_public_ip_on_launch = true
    
    tags = {
        Name        = "${var.project_name}-subnet"
        Environment = var.environment
        Owner       = var.owner
        Project     = "Terraform-Assignment6"
        ManagedBy   = "Terraform"
    }
}

# Route table for public subnet
resource "aws_route_table" "assignment6_rt" {
    vpc_id = aws_vpc.assignment6_vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.assignment6_igw.id
    }
    
    tags = {
        Name        = "${var.project_name}-rt"
        Environment = var.environment
        Owner       = var.owner
        Project     = "Terraform-Assignment6"
        ManagedBy   = "Terraform"
    }
}

# Route table association
resource "aws_route_table_association" "assignment6_rta" {
    subnet_id      = aws_subnet.assignment6_subnet.id
    route_table_id = aws_route_table.assignment6_rt.id
}

# EC2 Instance - Using t3.micro for better performance
resource "aws_instance" "assignment6_ec2" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id     = aws_subnet.assignment6_subnet.id
    
    tags = {
        Name        = "${var.project_name}-ec2-instance"
        Environment = var.environment
        Owner       = var.owner
        Project     = "Terraform-Assignment6"
        ManagedBy   = "Terraform"
        Purpose     = "Learning-Terraform"
    }
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]
    
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    
    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

