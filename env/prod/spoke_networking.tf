# ==============================================================================
# SPOKE VPC GATEWAY ENDPOINT (LOCAL DYNAMODB ACCESS)
# ==============================================================================

# Fetch the exact service name for DynamoDB in the Spoke region dynamically
data "aws_vpc_endpoint_service" "spoke_dynamodb" {
  provider = aws.spoke
  service  = "dynamodb"
}

resource "aws_vpc_endpoint" "spoke_dynamodb_endpoint" {
  provider          = aws.spoke
  vpc_id            = module.spoke_vpc.vpc_id
  service_name      = data.aws_vpc_endpoint_service.spoke_dynamodb.service_name
  vpc_endpoint_type = "Gateway"
  
  # Crucial: Attaching this to the private route tables natively intercepts the Boto3 call
  route_table_ids   = module.spoke_vpc.private_route_table_ids

  tags = {
    Name        = "${var.spoke_vpc_name}-dynamodb-vpce"
    Environment = var.environment
  }
}
