data "aws_region" "current" {}

module "human_policies" {
  source = "../../iam/iam-for-humans"
}

# ========================= Policy for iam-managers ====================================
# Allow iam-managers to fully manage all users
resource "aws_iam_group_policy_attachment" "iam-managers-full-access" {
  group      = aws_iam_group.main["iam-managers"].name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "iam-managers-analyzer-full-access" {
  group      = aws_iam_group.main["iam-managers"].name
  policy_arn = "arn:aws:iam::aws:policy/IAMAccessAnalyzerReadOnlyAccess"
}

# ========================= Policy for iam-managers ====================================

# ========================= Policy for administrators ====================================
# Gives admins full access to all systems
resource "aws_iam_group_policy_attachment" "administrators-all" {
  group      = "administrators"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

  depends_on = [
    aws_iam_group.main
  ]
}
# ========================= Policy for administrators ====================================

# ========================= Policy for engineer ====================================
resource "aws_iam_group_policy_attachment" "engineer" {
  count      = length(module.iam_policies.*.policy_arn)
  group      = "engineer"
  policy_arn = module.iam_policies.*.policy_arn[count.index]
}
# ========================= Policy for engineer ====================================

module "iam_policies" {
  count  = length(var.environment_tags_for_taggable_resources)
  source = "../../iam/iam-policy-for-taggable-resources"

  # Required
  environment = var.environment_tags_for_taggable_resources[count.index]
}

module "s3_iam_policies" {
  for_each = var.users
  source   = "../../iam/iam-policy-for-s3"

  project_access = each.value["project_access"]
  username       = each.value["iam"]
}

module "iam_ecs_policies" {
  source = "../../iam/iam-policy-for-ecs/core"

  for_each = var.users

  username       = each.value["iam"]
  project_access = each.value["project_access"]
  region         = data.aws_region.current.name

  # optional
  allow_listing_ecs = true
}

module "iam_cross_account_policies" {
  count  = var.iam_cross_account_config == null ? 0 : 1
  source = "../../iam/iam-policy-for-cross-account-access/destination-account"

  origin_aws_account_id = var.iam_cross_account_config.origin_aws_account_id
  policy_name           = "AdministratorAccess"
  aws_role_name         = var.iam_cross_account_config.assume_role_name
}
