terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.hub, aws.spoke]
    }
  }
}

resource "aws_vpc_peering_connection" "hub_to_spoke" {
  provider      = aws.hub
  vpc_id        = var.hub_vpc_id
  peer_vpc_id   = var.spoke_vpc_id
  peer_region   = var.spoke_region
  peer_owner_id = var.spoke_account_id
  auto_accept   = false

  tags = {
    Name = var.peering_name
  }
}

resource "aws_vpc_peering_connection_accepter" "spoke_accepts" {
  provider                  = aws.spoke
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_to_spoke.id
  auto_accept               = true

  tags = {
    Name = "${var.peering_name}-accepter"
  }
}

resource "aws_route" "hub_to_spoke_route" {
  provider                  = aws.hub
  route_table_id            = var.hub_route_table_id
  destination_cidr_block    = var.spoke_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_to_spoke.id
}

resource "aws_route" "spoke_to_hub_route" {
  provider                  = aws.spoke
  route_table_id            = var.spoke_route_table_id
  destination_cidr_block    = var.hub_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_to_spoke.id
}
