module "container-app" {
  source = "../container-app"

  resource_group_name = var.resource_group_name
  project             = var.project
  environment         = var.environment

  key_vault_id                 = azurerm_key_vault.main.id
  container_app_environment_id = azurerm_container_app_environment.main.id
  container_registry_name      = module.container-registry.name
  health_check_options         = var.container_app_config.health_check_options

  target_port                 = var.container_app_config.target_port
  exposed_port                = var.container_app_config.exposed_port
  user_assigned_identity_name = local.name
  cpu                         = var.container_app_config.cpu
  memory                      = var.container_app_config.memory
  environment_variables       = var.container_app_config.environment_variables
  secret_variables            = var.container_app_config.secret_variables
  image_version               = var.container_app_config.image_version

  depends_on = [
    azurerm_user_assigned_identity.main
  ]
}

