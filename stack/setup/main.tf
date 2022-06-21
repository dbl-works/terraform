locals {
  secret_vaults = {
    app = {
      description = "For applications to use inside containers"
    },
    terraform = {
      description = "Stores secrets for use in terraform workspace"
    }
  }
}

module "secrets" {
  source = "../../secrets"

  for_each   = local.secret_vaults
  kms_key_id = module.secrets-kms-key[each.key].id

  project     = var.project
  environment = var.environment

  # Optional
  application = each.key
  description = each.value.description
}


resource "aws_secretsmanager_secret_version" "app" {
  secret_id     = module.secrets["app"].id
  secret_string = file("${path.cwd}/app-secrets.json")
}

resource "aws_secretsmanager_secret_version" "terraform" {
  secret_id     = module.secrets["terraform"].id
  secret_string = file("${path.cwd}/terraform-secrets.json")
}

module "secrets-kms-key" {
  source = "../../kms-key"

  for_each = local.secret_vaults

  # Required
  environment = var.environment
  project     = var.project
  alias       = each.key
  description = "kms key for ${var.project} ${each.key} secrets"

  # Optional
  deletion_window_in_days = var.kms_deletion_window_in_days
}

resource "aws_acm_certificate" "main" {
  domain_name = var.domain

  subject_alternative_names = var.add_wildcard_subdomains ? ["*.${var.domain}"] : []

  validation_method = "DNS"

  tags = {
    Name        = var.domain
    Project     = var.project
    Environment = var.environment
  }
}

# domain validation
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = cloudflare_record.validation.*.hostname
}


## EIP
resource "aws_eip" "nat" {
  for_each = var.eips_nat_count

  vpc = true

  tags = {
    Name        = "${var.project}-nat-${var.environment}-${each.key}"
    Project     = var.project
    Environment = var.environment
  }
}
