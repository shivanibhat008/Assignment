# The single Central Metadata Cache Table
resource "aws_dynamodb_table" "metadata_cache" {
  provider     = aws.hub
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EventId"

  attribute {
    name = "EventId"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Purpose     = "CQRS-Read-Cache"
  }
}

# Secure VPC Gateway Endpoint forcing DynamoDB traffic off the public internet
resource "aws_vpc_endpoint" "hub_dynamodb" {
  provider          = aws.hub
  vpc_id            = module.hub_vpc.vpc_id
  service_name      = "com.amazonaws.${var.hub_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [module.hub_vpc.private_route_table_id]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = ["dynamodb:Query", "dynamodb:PutItem"]
      Resource  = "*"
      Condition = {
        StringEquals = {
          "aws:SourceVpc" = module.hub_vpc.vpc_id
        }
      }
    }]
  })
}
