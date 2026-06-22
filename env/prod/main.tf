# 1. Standardized Network Layer for Central Hub
module "hub_vpc" {
  source    = "../../modules/networking"
  providers = { aws = aws.hub }

  vpc_name            = var.hub_vpc_name
  vpc_cidr            = var.hub_vpc_cidr
  private_subnet_cidr = var.hub_private_subnet_cidr
  az                  = var.hub_az
  environment         = var.environment
}

# 2. Standardized Network Layer for Regional Spoke
module "spoke_vpc" {
  source    = "../../modules/networking"
  providers = { aws = aws.spoke }

  vpc_name            = var.spoke_vpc_name
  vpc_cidr            = var.spoke_vpc_cidr
  private_subnet_cidr = var.spoke_private_subnet_cidr
  az                  = var.spoke_az
  environment         = var.environment
}

# 3. Secure Multi-Account Cross-Region Peering Mesh
module "hub_to_spoke_peering" {
  source = "../../modules/vpc_peering"
  providers = {
    aws.hub   = aws.hub
    aws.spoke = aws.spoke
  }

  peering_name         = "peering-${var.environment}-hub-to-spoke"
  hub_vpc_id           = module.hub_vpc.vpc_id
  hub_vpc_cidr         = module.hub_vpc.vpc_cidr
  hub_route_table_id   = module.hub_vpc.private_route_table_id
  spoke_vpc_id         = module.spoke_vpc.vpc_id
  spoke_vpc_cidr       = module.spoke_vpc.vpc_cidr
  spoke_route_table_id = module.spoke_vpc.private_route_table_id
  spoke_region         = var.spoke_region
  spoke_account_id     = var.spoke_account_id
}
