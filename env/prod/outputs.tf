output "hub_vpc_id" {
  description = "The provisioned ID of the Central Hub VPC."
  value       = module.hub_vpc.vpc_id
}

output "spoke_vpc_id" {
  description = "The provisioned ID of the Regional Spoke VPC."
  value       = module.spoke_vpc.vpc_id
}

output "vpc_peering_connection_id" {
  description = "The active cross-region VPC Peering Connection ID connecting the Hub and Spoke."
  value       = module.transit_mesh.peering_connection_id
}

output "fargate_execution_role_arn" {
  description = "The strictly scoped IAM Execution Role ARN for the Spoke Fargate containers."
  value       = module.spoke_security.fargate_role_arn
}
