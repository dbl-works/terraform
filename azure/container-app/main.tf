data "azurerm_container_registry" "main" {
  name                = coalesce(var.container_registry_name, var.project)
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "main" {
  for_each = { for secret in var.secret_variables : secret => secret }

  name         = each.key
  key_vault_id = var.key_vault_id
}

data "azurerm_user_assigned_identity" "main" {
  name                = coalesce(var.user_assigned_identity_name, local.default_name)
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "main" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "acrpull"
  principal_id         = data.azurerm_user_assigned_identity.main.principal_id
}

# https://learn.microsoft.com/en-us/azure/container-apps/vnet-custom?tabs=bash%2Cazure-cli&pivots=azure-portal
resource "azurerm_container_app_environment" "main" {
  name                = local.default_name
  location            = var.region
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id       = var.subnet_id
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  log_analytics_workspace_id     = var.log_analytics_workspace_id

  tags = coalesce(var.tags, local.default_tags)
}


resource "azurerm_container_app" "main" {
  name                         = var.project
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  identity {
    type         = "UserAssigned"
    identity_ids = [data.azurerm_user_assigned_identity.main.id]
  }

  registry {
    server   = data.azurerm_container_registry.main.login_server
    identity = data.azurerm_user_assigned_identity.main.id
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = var.target_port
    exposed_port               = var.exposed_port
    transport                  = var.transport
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dynamic "secret" {
    for_each = toset(var.secret_variables)
    content {
      name  = secret.value
      value = data.azurerm_key_vault_secret.main[secret.value].value
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = coalesce(var.container_app_name, local.default_name)
      image  = "${data.azurerm_container_registry.main.login_server}/${coalesce(var.repository_name, var.project)}:${var.image_version}"
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = coalesce(local.env, {})
        content {
          name        = env.key
          secret_name = env.value.secret_name
          value       = env.value.value
        }
      }

      # Azure Container Apps health probes allow the Container Apps runtime to regularly inspect the status of your container apps.
      # Checks to see if a replica is ready to handle incoming requests.
      readiness_probe {
        port                    = var.health_check_options.port
        transport               = var.health_check_options.transport
        path                    = var.health_check_options.path
        interval_seconds        = var.health_check_options.interval_seconds
        timeout                 = var.health_check_options.timeout
        failure_count_threshold = var.health_check_options.failure_count_threshold
      }

      # Checks if your application is still running and responsive.
      liveness_probe {
        port                    = var.health_check_options.port
        transport               = var.health_check_options.transport
        path                    = var.health_check_options.path
        interval_seconds        = var.health_check_options.interval_seconds
        timeout                 = var.health_check_options.timeout
        failure_count_threshold = var.health_check_options.failure_count_threshold
      }

      # Checks if your application has successfully started. This check is separate from the liveness probe and executes during the initial startup phase of your application.
      startup_probe {
        port                    = var.health_check_options.port
        transport               = var.health_check_options.transport
        path                    = var.health_check_options.path
        interval_seconds        = 1
        timeout                 = 30 # TODO: @sam, make sure that this is align with the puma timeout
        failure_count_threshold = 3
      }
    }
  }

  tags = coalesce(var.tags, local.default_tags)
}

output "app_url" {
  value = azurerm_container_app.main.latest_revision_fqdn
}

output "revision_name" {
  value = azurerm_container_app.main.latest_revision_name
}

output "public_ip_address" {
  value = azurerm_container_app_environment.main.static_ip_address
}
