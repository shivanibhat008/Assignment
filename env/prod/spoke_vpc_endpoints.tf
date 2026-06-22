# ==============================================================================
# SPOKE GATEWAY ENDPOINT (LOCAL REPLICA ROUTING)
# ==============================================================================
# This ensures Fargate's writes to the local replica never touch the public internet.

data "aws_vpc_endpoint_service" "dynamodb" {
  provider = aws.spoke
  service  = "dynamodb"
}

resource "aws_vpc_endpoint" "spoke_dynamodb_gateway" {
  provider          = aws.spoke
  vpc_id            = module.spoke_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_endpoint_type = "Gateway"
  
  # Intercepts Boto3/SDK calls natively in the Spoke private subnets
  route_table_ids   = module.spoke_vpc.private_route_table_ids
}
