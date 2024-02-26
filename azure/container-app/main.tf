data "azurerm_container_app_environment" "main" {
  name                = local.name
  resource_group_name = var.resource_group_name
}

data "azurerm_container_registry" "main" {
  name                = var.project
  resource_group_name = var.resource_group_name
}

data "azurerm_user_assigned_identity" "main" {
  name                = var.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "main" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "acr_pull"
  principal_id         = data.azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_container_app" "main" {
  name                         = var.project
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

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
    traffic_weight {
      percentage = 100
    }

    transport = "Auto"
  }

  template {
    container {
      name   = local.name
      image  = data.azurerm_container_registry.main.login_server
      cpu    = var.cpu
      memory = var.memory

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
        timeout                 = 3
        failure_count_threshold = 240
      }
    }
  }

  tags = local.default_tags
}
