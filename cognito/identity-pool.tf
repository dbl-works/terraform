resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project}-${var.environment}"
  allow_unauthenticated_identities = false
  allow_classic_flow               = false
}
