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

# TODO: Add KMS key to secrets
# TODO: Allow more secrets to be declared if provided by users
module "secrets" {
  source = "../secrets"

  for_each = local.secret_vaults

  project     = var.project
  environment = var.environment

  # Optional
  application = each.key
  description = each.value.description
}

data "aws_secretsmanager_secret_version" "terraform" {
  secret_id = "${var.project}/terraform/${var.environment}"
}
