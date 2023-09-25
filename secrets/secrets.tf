# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

module "kms-key" {
  source = "../kms-key"

  count = var.kms_key_id == null ? 1 : 0

  environment = var.project
  project     = var.project
  alias       = var.application
  description = "Used for ecrypting secrets for ${var.application}."

  # Optional
  deletion_window_in_days = 30
  multi_region            = false
}

locals {
  kms_key_id = var.kms_key_id == null ? module.kms-key.id : var.kms_key_id
}

resource "aws_secretsmanager_secret" "main" {
  name        = "${var.project}/${var.application}/${var.environment}"
  description = try(var.description, "Secrets that are not to be stored inside ${var.application}.")
  kms_key_id  = local.kms_key_id

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
