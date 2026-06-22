# ==============================================================================
# GLOBAL ENVIRONMENT VARIABLES
# ==============================================================================

variable "environment" {
  description = "The target deployment tier environment name (e.g., prod, staging, dev). Configured to prevent accidental environmental cross-contamination."
  type        = string
  default     = "prod"
}

variable "cross_account_role_name" {
  description = "The name of the IAM role deployed in the Spoke account that the Central Hub automation pipeline assumes for cross-account resource management."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

# ==============================================================================
# CENTRAL HUB ACCOUNT VARIABLES
# ==============================================================================

variable "hub_region" {
  description = "The primary AWS region designated for hosting the centralized dashboard, logging aggregator, and global data planes."
  type        = string
  default     = "eu-west-1"
}

variable "hub_vpc_name" {
  description = "The explicit name tag assigned to the Central Hub VPC to isolate its infrastructure resources within the AWS console."
  type        = string
}

variable "hub_vpc_cidr" {
  description = "The primary IPv4 CIDR allocation for the Hub network. Must be strictly managed to prevent overlap with peered target regions."
  type        = string
}

variable "hub_private_subnet_cidr" {
  description = "The isolated private subnet CIDR segment inside the Central Hub VPC where the processing compute layer executes."
  type        = string
}

variable "hub_az" {
  description = "The target Availability Zone within the Hub region designated for private subnet resource placement."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The globally unique identifier for the central NoSQL DynamoDB cache, serving non-PII read queries for high availability."
  type        = string
}

# ==============================================================================
# REGIONAL SPOKE ACCOUNT VARIABLES
# ==============================================================================

variable "spoke_region" {
  description = "The regional destination where the remote edge processing networks and localized Fargate containers reside."
  type        = string
  default     = "us-east-2"
}

variable "spoke_account_id" {
  description = "The explicit 12-digit AWS Account ID owning the Spoke VPC network, required to authorize cross-account VPC peering requests."
  type        = string
}

variable "spoke_vpc_name" {
  description = "The unique identifier string attached to the Spoke VPC network fabric for tagging and logging segregation."
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "The distinct IPv4 network space assigned to the Spoke VPC. Must not overlap with any other connected environment."
  type        = string
}

variable "spoke_private_subnet_cidr" {
  description = "The dedicated private internal network slice where the local Fargate containers and Aurora databases operate."
  type        = string
}

variable "spoke_az" {
  description = "The explicit physical Availability Zone in the Spoke region where isolated resources will be spun up."
  type        = string
}
