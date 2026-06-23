# ==============================================================================
# PARTIAL BACKEND CONFIGURATION
# Values are injected at runtime via backend.hcl to keep this module DRY.
# ==============================================================================

terraform {
  backend "s3" {}
}
