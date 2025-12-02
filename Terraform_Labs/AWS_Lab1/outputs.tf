output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.assignment6_vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.assignment6_vpc.cidr_block
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = aws_subnet.assignment6_subnet.id
}

output "subnet_cidr_block" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.assignment6_subnet.cidr_block
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.assignment6_ec2.id
}

output "ec2_instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.assignment6_ec2.public_ip
}

output "ec2_instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.assignment6_ec2.private_ip
}

output "ec2_instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.assignment6_ec2.arn
}

