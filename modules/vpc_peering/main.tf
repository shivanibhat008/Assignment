# ==============================================================================
# ENABLE CROSS-VPC DNS RESOLUTION
# ==============================================================================

# 1. Modify the Requester Options (Hub)
resource "aws_vpc_peering_connection_options" "hub_dns_resolution" {
  provider                  = aws.hub
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_to_spoke.id

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  # Options can only be set after the connection is active
  depends_on = [aws_vpc_peering_connection_accepter.spoke_accepts_hub]
}

# 2. Modify the Accepter Options (Spoke)
resource "aws_vpc_peering_connection_options" "spoke_dns_resolution" {
  provider                  = aws.spoke
  vpc_peering_connection_id = aws_vpc_peering_connection.hub_to_spoke.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  depends_on = [aws_vpc_peering_connection_accepter.spoke_accepts_hub]
}
