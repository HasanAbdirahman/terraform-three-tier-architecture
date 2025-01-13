output "subnets_config" {
  value       = var.subnets_config
  description = "value of the subnets created for the VPC- that shows cidrblock and isPublic"
}

output "project_name" {
  value       = var.project_name
  description = "value of the project name"
}

output "instance_class" {
  value       = var.instance_class
  description = "value of the instance class created for the RDS instance"
}

output "storage_size" {
  value       = var.storage_size
  description = "value of the storage size created for the RDS instance. Must be between 5 and 10"
}

output "engine_name" {
  value       = var.engine
  description = "value of the engine created for the RDS instance. Must be postgres-14 or postgres-latest"
}

output "credentials" {
  value       = var.credentials
  description = "value of the credentials created for the RDS instance. Must be at least 8 characters long and contain at least one letter, one digit, and one special character"
  sensitive   = true
}

output "subnet_ids" {
  value       = var.subnet_ids
  description = "value of the subnet ids created for the RDS instance"
}

output "security_group_ids" {
  value       = var.security_group_ids
  description = "value of the security group created for the RDS instance"
}

output "db_engine" {
  value       = local.db_engine
  description = "value of the db engine, version and family created for the RDS instance"
}

output "private_subnet_ids" {
  value       = local.private_subnet_ids
  description = "value of the private subnet ids created for the RDS instance"
}

output "public_subnet_ids" {
  value       = local.public_subnet_ids
  description = "value of the public subnet ids created for the RDS instance"
}
