# ---------------------------------------------------------
# IAM: Central Lambda Execution Role
# ---------------------------------------------------------
resource "aws_iam_role" "lambda_router_role" {
  provider = aws.hub
  name     = "${var.hub_vpc_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Allow Lambda to attach to the private VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  provider   = aws.hub
  role       = aws_iam_role.lambda_router_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Allow Lambda to read from DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_read" {
  provider = aws.hub
  name     = "AllowDynamoDBRead"
  role     = aws_iam_role.lambda_router_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:Query", "dynamodb:PutItem"]
      Resource = aws_dynamodb_table.metadata_cache.arn
    }]
  })
}

# ---------------------------------------------------------
# COMPUTE: Central Lambda Router
# ---------------------------------------------------------
resource "aws_lambda_function" "central_router" {
  provider      = aws.hub
  function_name = "protex-central-api-router"
  role          = aws_iam_role.lambda_router_role.arn
  handler       = "router.handler"
  runtime       = "python3.11"
  
  filename         = "dummy_payload.zip" 
  source_code_hash = filebase64sha256("dummy_payload.zip")

  vpc_config {
    subnet_ids         = [module.hub_vpc.private_subnet_id]
    security_group_ids = [aws_security_group.hub_lambda_router_sg.id]
  }
}

# ---------------------------------------------------------
# NETWORKING: Central ALB
# ---------------------------------------------------------
resource "aws_lb" "central_api_alb" {
  provider           = aws.hub
  name               = "${var.hub_vpc_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.hub_internal_alb_sg.id]
  subnets            = var.hub_public_subnet_ids # Assuming you added public subnets
}

# ---------------------------------------------------------
# INGRESS: AWS Global Accelerator
# ---------------------------------------------------------
resource "aws_globalaccelerator_accelerator" "protex_global" {
  provider        = aws.hub
  name            = "protex-global-entry"
  ip_address_type = "IPV4"
  enabled         = true
}

resource "aws_globalaccelerator_listener" "https" {
  provider        = aws.hub
  accelerator_arn = aws_globalaccelerator_accelerator.protex_global.arn
  protocol        = "TCP"

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "hub_primary" {
  provider              = aws.hub
  listener_arn          = aws_globalaccelerator_listener.https.arn
  endpoint_group_region = var.hub_region

  endpoint_configuration {
    endpoint_id = aws_lb.central_api_alb.arn
  }
}
