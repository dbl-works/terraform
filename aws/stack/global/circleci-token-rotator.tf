module "circleci-token-rotator" {
  count  = var.circleci_token_rotator == null ? 0 : 1
  source = "../../circleci-token-rotator"

  project                           = var.project
  circle_ci_organization_id         = var.circleci_token_rotator.organization_id
  context_name                      = var.circleci_token_rotator.context_name
  user_name                         = module.deploy-bot.user_name
  cloudwatch_logs_retention_in_days = var.circleci_token_rotator.cloudwatch_logs_retention_in_days
}
