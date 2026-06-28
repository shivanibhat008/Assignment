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

 Germany Spoke
provider "aws" {
  alias  = "germany"
  region = "eu-central-1"

  assume_role {
    role_arn = var.germany_execution_role_arn
  }
}

# France Spoke
provider "aws" {
  alias  = "france"
  region = "eu-west-3"

  assume_role {
    role_arn = var.france_execution_role_arn
  }
}
