output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "private_route_table_id" {
  description = "The ID of the private route table for peering and endpoint attachments"
  value       = aws_route_table.private.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC for security group whitelisting"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}
