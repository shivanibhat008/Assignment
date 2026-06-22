output "vpc_peering_connection_id" {
  description = "The ID of the VPC Peering Connection"
  value       = aws_vpc_peering_connection.hub_to_spoke.id
}

output "vpc_peering_accept_status" {
  description = "The acceptance status of the VPC Peering Connection"
  value       = aws_vpc_peering_connection_accepter.spoke_accepts.accept_status
}
