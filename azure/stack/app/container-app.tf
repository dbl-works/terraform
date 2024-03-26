# A Container Apps environment is a secure boundary around groups of container apps that share the same virtual network and write logs to the same logging destination.
# module "container-app" {
#   source = "../../container-app"
#
#   container_app_name           = var.container_app_config.name
#   resource_group_name          = var.resource_group_name
#   project                      = var.project
#   environment                  = var.environment
#   region                       = var.region
#   log_analytics_workspace_name = var.container_app_config.log_analytics_workspace_name
#   logs_retention_in_days       = var.container_app_config.logs_retention_in_days
#
#   key_vault_id                    = var.key_vault_id
#   container_registry_id           = module.container-registry.id
#   container_registry_login_server = module.container-registry.login_server
#   health_check_options            = var.container_app_config.health_check_options
#
#   custom_domain = var.container_app_config.custom_domain
#   command       = var.container_app_config.command
#
#   target_port  = var.container_app_config.target_port
#   exposed_port = 0
#   transport    = "auto"
#   subnet_id    = module.virtual-network.public_subnet_id
#
#   user_assigned_identity_name = var.user_assigned_identity_name
#   cpu                         = var.container_app_config.cpu
#   memory                      = var.container_app_config.memory
#   environment_variables       = var.container_app_config.environment_variables
#   secret_variables            = var.container_app_config.secret_variables
#   image_version               = var.container_app_config.image_version
#   tags                        = var.tags
# }


# output "container_app_environment_id" {
#   value = module.container-app.container_app_environment_id
# }
