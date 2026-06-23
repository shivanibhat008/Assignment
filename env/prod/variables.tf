# ------------------------------------------------------------------------------
# GLOBAL VARIABLES
# ------------------------------------------------------------------------------
variable "project_name" {
  description = "The primary project identifier."
  type        = string
  default     = "protex"
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

variable "hub_private_subnets" {
  description = "A list of IPv4 CIDR blocks for the Hub's private subnets."
  type        = list(string)
}

variable "hub_azs" {
  description = "A list of Availability Zones for the Hub deployment."
  type        = list(string)
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

variable "spoke_private_subnets" {
  description = "A list of IPv4 CIDR blocks for the Spoke's private subnets."
  type        = list(string)
}

variable "spoke_azs" {
  description = "A list of Availability Zones for the Spoke deployment."
  type        = list(string)
}
