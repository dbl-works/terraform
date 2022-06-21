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

module "aws-acm-certificate" {
  source = "../../certificate"

  project     = var.project
  environment = var.environment
  domain_name = var.domain

  # Optional
  add_wildcard_subdomains = var.add_wildcard_subdomains
}

# domain validation
resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = cloudflare_record.validation.*.hostname
}


## EIP
resource "aws_eip" "nat" {
  count = var.eips_nat_count # 1 NAT/IP per region

  vpc = true

  tags = {
    Name        = "${var.project}-nat-${var.environment}-${count.index + 1}"
    Project     = var.project
    Environment = var.environment
  }
}
