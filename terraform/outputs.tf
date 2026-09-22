output "vpc_id" {
  description = "Project 5 VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Project 5 public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Project 5 private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "availability_zones" {
  description = "Project 5 Availability Zones"
  value       = module.vpc.availability_zones
}