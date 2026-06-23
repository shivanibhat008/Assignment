terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  alias  = "hub"
  region = var.hub_region
}

provider "aws" {
  alias  = "spoke"
  region = var.spoke_region
}
