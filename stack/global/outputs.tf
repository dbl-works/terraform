output "ip_sets" {
  value = var.global_accelerator_config == null ? "" : module.global-accelerator[0].ip_sets
}

output "dns_name" {
  value = var.global_accelerator_config == null ? "" : module.global-accelerator[0].dns_name
}

output "circleci_token_rotator" {
  value = var.circleci_token_rotator == null ? "not enabled" : "CircleCI Token Rotator enabled. Please set 'CIRCLE_CI_TOKEN' in the AWS vault 'TODO: VAULT NAME HERE'."
}
