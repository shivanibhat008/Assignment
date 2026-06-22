# ==============================================================================
# GLOBAL DYNAMODB METADATA CACHE (CQRS READ MODEL)
# ==============================================================================

resource "aws_dynamodb_table" "global_metadata_cache" {
  provider       = aws.hub
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST" # Serverless pricing model
  hash_key       = "EventID"

  attribute {
    name = "EventID"
    type = "S"
  }

  # ---------------------------------------------------------
  # REQUIRED FOR GLOBAL TABLES
  # ---------------------------------------------------------
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  # ---------------------------------------------------------
  # REGIONAL REPLICATION
  # ---------------------------------------------------------
  replica {
    region_name = var.spoke_region
    # AWS automatically handles the cross-region sync over its internal backbone
  }

  tags = {
    Environment = var.environment
    Purpose     = "Global Observability Read Cache"
    SLA         = "99.999"
  }
}
