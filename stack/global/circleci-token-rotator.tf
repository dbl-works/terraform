module "circleci-token-rotator" {
  count  = var.circle_ci_token_rotator == null ? 0 : 1
  source = "../../circleci-token-rotator"

  project                   = var.project
  circle_ci_organization_id = var.circle_ci_token_rotator.organization_id
  context_name              = var.circle_ci_token_rotator.context_name
  user_name                 = module.deploy-bot.user_name
}
