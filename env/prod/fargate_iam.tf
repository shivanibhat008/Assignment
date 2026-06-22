# ==============================================================================
# FARGATE IAM EXECUTION POLICY (LEAST PRIVILEGE)
# ==============================================================================

resource "aws_iam_role_policy" "fargate_local_dynamodb_write" {
  provider = aws.spoke
  name     = "AllowLocalDynamoDBWriteOnly"
  role     = aws_iam_role.spoke_fargate_role.id # Assuming your existing Fargate role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        # STRICT BOUNDARY: The ARN is mathematically locked to the local Spoke region
        Resource = "arn:aws:dynamodb:${var.spoke_region}:${var.spoke_account_id}:table/${var.dynamodb_table_name}"
      }
    ]
  })
}
