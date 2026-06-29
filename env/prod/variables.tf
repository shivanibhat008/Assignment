# ------------------------------------------------------------------------------
# GLOBAL VARIABLES
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The primary project identifier."
  type        = string
  default     = "assignment"
}

variable "environment" {
  description = "The target deployment environment."
  type        = string
  default     = "prod"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table bridging the Hub and Spoke."
  type        = string
}

# ------------------------------------------------------------------------------
# CENTRAL HUB VARIABLES (e.g., eu-central-1)
# ------------------------------------------------------------------------------
variable "hub_region" {
  description = "The primary AWS region for the Central Hub deployment."
  type        = string
}

variable "hub_vpc_cidr" {
  description = "The primary IPv4 CIDR block for the Central Hub VPC."
  type        = string
}

variable "hub_private_subnet_count" {
    type = number
}

variable "hub_role_arn" {
  description = "IAM role assumed in the Hub AWS account"
  type        = string
}

variable "spoke_role_arn" {
  description = "IAM role assumed in the Spoke AWS account"
  type        = string
}
# ------------------------------------------------------------------------------
# REGIONAL SPOKE VARIABLES (e.g., eu-west-1)
# ------------------------------------------------------------------------------
variable "spoke_region" {
  description = "The target AWS region for the Data Sovereignty Spoke deployment."
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "The primary IPv4 CIDR block for the Regional Spoke VPC."
  type        = string
}

variable "spoke_private_subnet_count" {
    type = number
}
