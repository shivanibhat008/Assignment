resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {

  count = var.private_subnet_count
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(var.vpc_cidr,8,count.index)

    availability_zone =
    data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
    for_each = {
      for subnet in aws_subnet.private :
      subnet.id => subnet
    }
    subnet_id      = each.value.id
    route_table_id = aws_route_table.private.id
}
# Dynamic Gateway Endpoint for DynamoDB
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-dynamodb-endpoint"
  }
}
