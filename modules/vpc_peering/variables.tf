variable "peering_name" {
  description = "Name tag for the VPC Peering Connection"
  type        = string
}

variable "hub_vpc_id" {
  description = "The VPC ID of the Central Hub (Requester)"
  type        = string
}

variable "hub_vpc_cidr" {
  description = "The CIDR block of the Central Hub for Spoke routing"
  type        = string
}

variable "hub_route_table_id" {
  description = "The ID of the Hub's private route table"
  type        = string
}

variable "spoke_vpc_id" {
  description = "The VPC ID of the Regional Spoke (Accepter)"
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "The CIDR block of the Spoke for Hub routing"
  type        = string
}

variable "spoke_route_table_id" {
  description = "The ID of the Spoke's private route table"
  type        = string
}

variable "spoke_region" {
  description = "The AWS region of the Spoke VPC"
  type        = string
}

variable "spoke_account_id" {
  description = "The AWS Account ID of the Spoke VPC owner"
  type        = string
}
