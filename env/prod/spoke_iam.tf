# ==============================================================================
# FARGATE IAM: STRICT LOCAL REPLICA WRITE ACCESS
# ==============================================================================

resource "aws_iam_role_policy" "fargate_local_replica_access" {
  provider = aws.spoke
  name     = "DynamoDBLocalReplicaWriteOnly"
  role     = aws_iam_role.spoke_fargate_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        # MATHEMATICALLY LOCKED: Fargate can ONLY write to its local Spoke replica.
        Resource = "arn:aws:dynamodb:${var.spoke_region}:${var.aws_account_id}:table/observability-events"
      }
    ]
  })
}
