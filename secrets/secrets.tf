# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret

resource "aws_secretsmanager_secret" "main" {
  name        = "${var.project}/${var.application}/${var.environment}"
  description = try(var.secretsmanager_description, "Secrets that are not to be stored inside ${var.application}.")

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
