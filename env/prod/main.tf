variable "environment" { type = string }
variable "cross_account_role_name" { type = string }

# Hub
variable "hub_region" { type = string }
variable "hub_vpc_name" { type = string }
variable "hub_vpc_cidr" { type = string }
variable "hub_private_subnet_cidr" { type = string }
variable "hub_az" { type = string }
variable "dynamodb_table_name" { type = string }

# Spoke
variable "spoke_region" { type = string }
variable "spoke_account_id" { type = string }
variable "spoke_vpc_name" { type = string }
variable "spoke_vpc_cidr" { type = string }
variable "spoke_private_subnet_cidr" { type = string }
variable "spoke_az" { type = string }
