terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  alias  = "hub"
  region = var.hub_region
assume_role {
    role_arn = var.hub_role_arn
  }
}

provider "aws" {
  alias  = "spoke"
  region = var.spoke_region
assume_role {
    role_arn = var.spoke_role_arn
  }
}
