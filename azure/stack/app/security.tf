module "security" {
  source = "../../security"

  count = var.enable_defender ? 1 : 0

  devop_email      = var.security_config.devop_email
  alerts_to_admins = var.security_config.alerts_to_admins
}
