# ==========================================
# 1. FOUNDATION: BASE VPCs
# ==========================================
module "hub_vpc" {
  source = "../../modules/networking"
  providers = { aws = aws.hub }

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.hub_vpc_cidr
  private_subnet_cidrs = var.hub_private_subnets
  availability_zones   = var.hub_azs
}


# ==========================================
# 2. SECURITY: ZERO-TRUST BOUNDARIES & IAM
# ==========================================
module "hub_security" {
  source = "../../modules/security"
  providers = { aws = aws.hub }

  project_name        = var.project_name
  environment         = var.environment
  hub_vpc_id          = module.hub_vpc.vpc_id
  hub_vpc_cidr        = var.hub_vpc_cidr
  dynamodb_table_name = var.dynamodb_table_name
}

# ==========================================
# 2. TRANSIT: CROSS-REGION PEERING MESH
# ==========================================
module "germany_peering" {
  source = "../../modules/vpc_peering"
  providers = {
    aws       = aws.hub
    aws.spoke = aws.germany
  }

  project_name = var.project_name
  environment  = var.environment

  hub_vpc_id         = module.hub_vpc.vpc_id
  hub_vpc_cidr       = var.hub_vpc_cidr
  hub_route_table_id = module.hub_vpc.private_route_table_id

  spoke_vpc_id         = var.germany_vpc_id
  spoke_vpc_cidr       = var.germany_cidr
  spoke_route_table_id = var.germany_route_table
  spoke_region         = "eu-central-1"
}


module "france_peering" {
  source = "../../modules/vpc_peering"
  providers = {
    aws       = aws.hub
    aws.spoke = aws.france
  }

  project_name = var.project_name
  environment  = var.environment

  hub_vpc_id         = module.hub_vpc.vpc_id
  hub_vpc_cidr       = var.hub_vpc_cidr
  hub_route_table_id = module.hub_vpc.private_route_table_id

  spoke_vpc_id         = var.france_vpc_id
  spoke_vpc_cidr       = var.france_cidr
  spoke_route_table_id = var.france_route_table
  spoke_region         = "eu-west-3"
}
