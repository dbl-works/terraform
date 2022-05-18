locals {
  secret_vaults = {
    app = {
      description = "For applications to use inside containers"
    },
    terraform = {
      description = "Stores secrets for use in terraform workspace"
    }
  }

  credentials = jsondecode(
    data.aws_secretsmanager_secret_version.terraform.secret_string
  )
}

module "secrets" {
  source = "github.com/dbl-works/terraform//secrets?ref=${var.module_version}"

  for_each = locals.secret_vaults

  project     = var.project
  environment = var.environment

  # Optional
  application                = each.key
  secretsmanager_description = each.value.description
}

data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = "${var.project}/terraform/${var.environment}"
}
