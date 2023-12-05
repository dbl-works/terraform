module "circleci-token-rotator" {
  count  = var.circleci_token_rotator_config == null ? 0 : 1
  source = "../../circleci-token-rotator"

  project                   = var.project
  circle_ci_organization_id = var.circleci_token_rotator_config.circle_ci_organization_id

  # Optional
  context_name                 = var.circleci_token_rotator_config.context_name
  user_name                    = var.circleci_token_rotator_config.user_name
  token_rotation_interval_days = var.circleci_token_rotator_config.token_rotation_interval_days
  timeout                      = var.circleci_token_rotator_config.timeout
  memory_size                  = var.circleci_token_rotator_config.memory_size
}
