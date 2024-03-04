module "container-app" {
  source = "../container-app"

  resource_group_name        = var.resource_group_name
  project                    = var.project
  environment                = var.environment
  environment_variables      = var.container_app_config.environment_variables
  secret_variables           = var.container_app_config.secret_variables
  target_port                = var.container_app_config.target_port
  exposed_port               = var.container_app_config.exposed_port
  user_assigned_identity_ids = [azurerm_user_assigned_identity.main.id]
  cpu                        = var.container_app_config.cpu
  memory                     = var.container_app_config.memory
  image_version              = var.container_app_config.image_version
  health_check_options       = var.container_app_config.health_check_options
}
