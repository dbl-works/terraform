# NOTE: https://github.com/microsoft/azure-container-apps/issues/1159
# Container App cannot be create because it can't access key vault

# NOTE: During the creation of container app environment,
# The access of key vault key must be enabled
# If the access is disabled, terraform will throw error.
module "container-app" {
  source = "../../container-app"

  container_apps             = var.container_app_config.container_apps
  container_app_name         = var.container_app_config.name
  resource_group_name        = var.resource_group_name
  project                    = var.project
  environment                = var.environment
  region                     = var.region
  log_analytics_workspace_id = module.observability.log_analytics_workspace_id
  logs_retention_in_days     = var.container_app_config.logs_retention_in_days

  key_vault_name                  = var.key_vault_name
  container_registry_login_server = module.container-registry.login_server
  health_check_options            = var.container_app_config.health_check_options
  zone_redundancy_enabled         = var.container_app_config.zone_redundancy_enabled

  username = var.container_app_config.username
  password_secret_name  = var.container_app_config.password_secret_name

  custom_domain = var.container_app_config.custom_domain
  target_port   = var.container_app_config.target_port
  exposed_port  = 0
  transport     = "auto"

  # Error Message: The Container Apps Environment failed to provision: ErrorCode: ManagedEnvironmentResourceDisallowedByPolicy,
  # Message: Fail to create managed environment because creation of required resources was disallowed by policy
  # Github Issues: https://github.com/microsoft/azure-container-apps/issues/559
  # We are not allowed to create Container App Environment with external ingress traffic
  subnet_id = module.virtual-network.private_subnet_id

  user_assigned_identity_name = var.user_assigned_identity_name
  environment_variables       = var.container_app_config.environment_variables
  secret_variables            = var.container_app_config.secret_variables
  image_version               = var.container_app_config.image_version
  tags                        = merge(var.container_app_config.tags, var.tags)
}
