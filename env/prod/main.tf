# ==========================================
# 1. FOUNDATION: BASE VPCs
# ==========================================
module "hub_vpc" {
  source = "../../modules/vpc"
  providers = { aws = aws.hub }

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.hub_vpc_cidr
  private_subnet_cidrs = var.hub_private_subnets
  availability_zones   = var.hub_azs
}

module "spoke_vpc" {
  source = "../../modules/vpc"
  providers = { aws = aws.spoke }

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.spoke_vpc_cidr
  private_subnet_cidrs = var.spoke_private_subnets
  availability_zones   = var.spoke_azs
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
  spoke_vpc_id        = module.spoke_vpc.vpc_id
  dynamodb_table_name = var.dynamodb_table_name
}

module "spoke_security" {
  source = "../../modules/security"
  providers = { aws = aws.spoke }

  project_name        = var.project_name
  environment         = var.environment
  hub_vpc_id          = module.hub_vpc.vpc_id
  hub_vpc_cidr        = var.hub_vpc_cidr
  spoke_vpc_id        = module.spoke_vpc.vpc_id
  dynamodb_table_name = var.dynamodb_table_name
}

# ==========================================
# 3. TRANSIT: CROSS-REGION PEERING MESH
# ==========================================
module "transit_mesh" {
  source = "../../modules/peering"
  # Passes default aws to hub, but explicitly requires the spoke provider for the Accepter
  providers = { aws = aws.hub }

  project_name         = var.project_name
  environment          = var.environment
  
  hub_vpc_id           = module.hub_vpc.vpc_id
  hub_vpc_cidr         = var.hub_vpc_cidr
  hub_route_table_id   = module.hub_vpc.private_route_table_id
  
  spoke_region         = var.spoke_region
  spoke_vpc_id         = module.spoke_vpc.vpc_id
  spoke_vpc_cidr       = var.spoke_vpc_cidr
  spoke_route_table_id = module.spoke_vpc.private_route_table_id
}
