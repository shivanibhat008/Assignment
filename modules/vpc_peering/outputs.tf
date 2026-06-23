output "peering_connection_id" {
  description = "The ID of the established, active cross-region VPC Peering Connection."
  value       = aws_vpc_peering_connection.mesh.id
}

output "hub_route_id" {
  description = "The ID of the route injected into the Hub's route table."
  value       = aws_route.hub_to_spoke.id
}

output "spoke_route_id" {
  description = "The ID of the route injected into the Spoke's route table."
  value       = aws_route.spoke_to_hub.id
}
