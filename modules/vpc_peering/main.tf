# 1. The Connection (Requester)
resource "aws_vpc_peering_connection" "mesh" {
  vpc_id      = var.hub_vpc_id
  peer_vpc_id = var.spoke_vpc_id
  peer_region = var.spoke_region

  tags = {
    Name = "${var.project_name}-${var.environment}-transit-mesh"
  }
}

# 2. The Connection (Accepter - requires aliased provider in root)
resource "aws_vpc_peering_connection_accepter" "mesh_accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.mesh.id
  auto_accept               = true

  tags = {
    Name = "${var.project_name}-${var.environment}-transit-accepter"
  }
}

# 3. Cross-VPC DNS Resolution Options
resource "aws_vpc_peering_connection_options" "hub_dns" {
  vpc_peering_connection_id = aws_vpc_peering_connection.mesh.id
  requester { allow_remote_vpc_dns_resolution = true }
  depends_on = [aws_vpc_peering_connection_accepter.mesh_accepter]
}

resource "aws_vpc_peering_connection_options" "spoke_dns" {
  vpc_peering_connection_id = aws_vpc_peering_connection.mesh.id
  accepter { allow_remote_vpc_dns_resolution = true }
  depends_on = [aws_vpc_peering_connection_accepter.mesh_accepter]
}

# 4. Layer 3 Route Injections
resource "aws_route" "hub_to_spoke" {
  route_table_id            = var.hub_route_table_id
  destination_cidr_block    = var.spoke_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mesh.id
}

resource "aws_route" "spoke_to_hub" {
  route_table_id            = var.spoke_route_table_id
  destination_cidr_block    = var.hub_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mesh.id
}
