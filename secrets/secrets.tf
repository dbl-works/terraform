# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

resource "aws_secretsmanager_secret" "main" {
  name        = "${var.project}/${var.application}/${var.environment}"
  description = try(var.description, "Secrets that are not to be stored inside ${var.application}.")
  kms_key_id  = var.kms_key_id

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
