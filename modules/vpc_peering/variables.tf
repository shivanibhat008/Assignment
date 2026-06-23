variable "project_name" {
  description = "The overarching name of the project."
  type        = string
}

variable "environment" {
  description = "The deployment environment."
  type        = string
}

variable "hub_vpc_id" {
  description = "The VPC ID of the Central Hub (Requester)."
  type        = string
}

variable "hub_vpc_cidr" {
  description = "The CIDR block of the Central Hub, used to inject return routes into the Spoke."
  type        = string
}

variable "hub_route_table_id" {
  description = "The ID of the Hub's private route table to inject the peering route."
  type        = string
}

variable "spoke_vpc_id" {
  description = "The VPC ID of the Regional Spoke (Accepter)."
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "The CIDR block of the Regional Spoke, used to inject outbound routes into the Hub."
  type        = string
}

variable "spoke_route_table_id" {
  description = "The ID of the Spoke's private route table to inject the peering route."
  type        = string
}

variable "spoke_region" {
  description = "The AWS Region of the Spoke VPC, required by the peering connection requester."
  type        = string
}
