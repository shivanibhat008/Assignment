variable "project_name" {
  description = "The overarching name of the project (used for resource tagging)."
  type        = string
}

variable "environment" {
  description = "The deployment environment (e.g., prod, staging, dev)."
  type        = string
}

variable "vpc_cidr" {
  description = "The primary IPv4 CIDR block for the VPC."
  type        = string
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 2
}

variable "enable_dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}
