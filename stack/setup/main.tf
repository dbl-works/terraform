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

module "kms-key-replica-rds" {
  source = "../../kms-key-replica"
  count  = var.rds_cross_region_kms_key_arn == null ? 0 : 1

  master_kms_key_arn = var.rds_cross_region_kms_key_arn
  environment        = var.environment
  project            = var.project
  alias              = "rds"
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
  count = var.is_read_replica_on_same_domain ? 0 : 1

  domain_name = var.domain

  subject_alternative_names = flatten(concat(
    var.add_wildcard_subdomains ? ["*.${var.domain}"] : [],
    var.alternative_domains,
  ))

  validation_method = "DNS"

  tags = {
    Name        = var.domain
    Project     = var.project
    Environment = var.environment
  }

  # When attached to a load balancer it cannot be destroyed.
  # This means we need to create a new one, attach it, then destroy the original.
  lifecycle {
    create_before_destroy = true
  }
}

## EIP
resource "aws_eip" "nat" {
  count = var.eips_nat_count # 1 per NAT / AZ

  vpc = true

  tags = {
    Name        = "${var.project}-nat-${var.environment}-${count.index + 1}"
    Project     = var.project
    Environment = var.environment
  }
}
