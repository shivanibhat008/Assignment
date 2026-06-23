output "vpc_id" {
  description = "The ID of the provisioned VPC."
  value       = aws_vpc.this.id
}

output "private_route_table_id" {
  description = "The ID of the private route table used for endpoint and peering injections."
  value       = aws_route_table.private.id
}

output "dynamodb_gateway_endpoint_id" {
  description = "The ID of the VPC Gateway Endpoint for DynamoDB."
  value       = aws_vpc_endpoint.dynamodb.id
}
