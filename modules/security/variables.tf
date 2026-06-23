variable "project_name" {
  description = "The overarching name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "hub_vpc_id" {
  description = "The ID of the Central Hub VPC where the Lambda execution SG will be deployed."
  type        = string
}

variable "hub_vpc_cidr" {
  description = "The CIDR block of the Central Hub VPC, used to whitelist peering ingress to the Spoke."
  type        = string
}

variable "spoke_vpc_id" {
  description = "The ID of the Regional Spoke VPC where the Internal ALB SG will be deployed."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The exact name of the DynamoDB Global Table to construct strict IAM execution policies."
  type        = string
}
