####################
# Subnet Configuration
####################
variable "subnets_config" {
  type = list(object({
    cidr_block = string
    isPublic   = optional(bool, false)
  }))
  validation {
    condition = alltrue([
      for subnet in var.subnets_config : can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "The subnet cidr must be have valid CIDR block"
  }
}


####################
# DB Configuration
####################
variable "project_name" {
  type    = string
  default = "Terraform-Three-Tier-Project"
}

variable "instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "value of the instance class created for the RDS instance"
  validation {
    condition     = contains(["db.t3.micro"], var.instance_class)
    error_message = "value must be db.t3.micro"
  }
}

variable "storage_size" {
  type        = number
  default     = 10
  description = "value of the storage size created for the RDS instance. Must be between 5 and 10"
  validation {
    condition     = var.storage_size >= 5 && var.storage_size <= 10
    error_message = "value must be between 5 and 10"
  }
}

variable "engine" {
  type        = string
  default     = "postgres-14"
  description = "value of the engine created for the RDS instance. Must be postgres-14 or postgres-latest"
  validation {
    condition     = contains(["postgres-14", "postgres-latest"], var.engine)
    error_message = "value must be postgres-14 or postgres-latest"
  }
}

variable "credentials" {
  type = object({
    username = string
    password = string
  })
  sensitive   = true
  description = "value of the credentials created for the RDS instance. Must be at least 8 characters long and contain at least one letter, one digit, and one special character"
  validation {
    condition = (
      length(regexall("[a-zA-Z]+", var.credentials.password)) >= 1
      && length(regexall("[0-9]+", var.credentials.password)) >= 1
      && length(regexall("^[a-zA-Z0-9+-_?]{8,}$", var.credentials.password)) >= 1
    )
    error_message = <<-EOT
    Password must only contain at least one letter, one digit, and be at least 8 characters long.
    Password can also have this special characters +, -, _, ? 
    EOT
  }
}
variable "kms_key_id" {
  type        = string
  description = "KMS key ID to encrypt RDS storage. If not set, the default key is used."
  default     = null
}

####################
# DB Network Configuration
####################

variable "subnet_ids" {
  type        = list(string)
  description = "value of the subnets created for the RDS instance"
}
variable "security_group_ids" {
  type        = list(string)
  description = "value of the security group created for the RDS instance"

}
