# ==============================================================================
# 1. DEPLOY THE BASE VPCS
# ==============================================================================

# Create the Hub VPC
module "hub_vpc" {
  source = "../../modules/networking"
  providers = { aws = aws.hub }

  vpc_cidr             = "10.0.0.0/16"
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  # ... other vpc variables ...
}

# Create the Spoke VPC (eu-west-1)
module "spoke_vpc" {
  source = "../../modules/networking"
  providers = { aws = aws.spoke }

  vpc_cidr             = "10.1.0.0/16"
  private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
  # ... other vpc variables ...
}

# ==============================================================================
# 2. DEPLOY THE CROSS-REGION PEERING MESH
# ==============================================================================

# Call the peering module directly, passing the outputs from the VPCs above in-memory
module "cross_region_peering" {
  source = "../../modules/vpc_peering"
  
  providers = {
    aws.hub   = aws.hub
    aws.spoke = aws.spoke
  }

  # Direct variable passing (No remote state required)
  hub_vpc_id     = module.hub_vpc.vpc_id
  hub_vpc_cidr   = "10.0.0.0/16"
  
  spoke_region   = "eu-west-1"
  spoke_vpc_id   = module.spoke_vpc.vpc_id
  spoke_vpc_cidr = "10.1.0.0/16"
}
