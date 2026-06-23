data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ==========================================
# LAYER 4 NETWORK BOUNDARIES (SECURITY GROUPS)
# ==========================================

resource "aws_security_group" "hub_lambda_sg" {
  name        = "${var.project_name}-${var.environment}-lambda-sg"
  description = "Controls egress for Central Hub Lambda"
  vpc_id      = var.hub_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "spoke_alb_sg" {
  name        = "${var.project_name}-${var.environment}-spoke-alb-sg"
  description = "Strict Zero-Trust boundary for cross-region media fetch"
  vpc_id      = var.spoke_vpc_id

  ingress {
    description = "Allow HTTPS purely from Hub VPC CIDR over Peering Link"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.hub_vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# LEAST-PRIVILEGE IAM EXECUTION ROLES
# ==========================================

# 1. Spoke Fargate Role (Write to Local Replica)
resource "aws_iam_role" "spoke_fargate_task" {
  name = "${var.project_name}-${var.environment}-fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "fargate_dynamodb_write" {
  name   = "DynamoDBLocalReplicaWrite"
  role   = aws_iam_role.spoke_fargate_task.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:PutItem", "dynamodb:UpdateItem"]
      # Dynamically constructed ARN locking write access strictly to the local region
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
    }]
  })
}

# 2. Hub Lambda Role (Read from Master Table)
resource "aws_iam_role" "hub_lambda_execution" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.hub_lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "lambda_dynamodb_read" {
  name   = "DynamoDBMasterRead"
  role   = aws_iam_role.hub_lambda_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:Query", "dynamodb:GetItem"]
      Resource = "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}*"
    }]
  })
}
