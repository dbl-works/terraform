locals {
  user_assigned_identity_name = coalesce(var.user_assigned_identity_name, local.default_name)
}

data "azurerm_subscription" "current" {}

data "azurerm_user_assigned_identity" "main" {
  name                = local.user_assigned_identity_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_container_app" "main" {
  name                         = coalesce(var.container_app_name, local.default_name)
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode

  identity {
    type = "UserAssigned"
    identity_ids = [
      data.azurerm_user_assigned_identity.main.id
    ]
  }

  registry {
    server   = var.container_registry_login_server
    identity = data.azurerm_user_assigned_identity.main.id
  }

  ingress {
    allow_insecure_connections = false
    external_enabled           = true
    target_port                = coalesce(var.target_port, local.default_app_port)
    # exposed_port can only be specified when transport is set to tcp.
    # exposed_port = coalesce(var.exposed_port, local.default_app_port)
    transport = var.transport

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    dynamic "custom_domain" {
      for_each = var.custom_domain == null ? [] : [1]

      content {
        certificate_binding_type = var.custom_domain.certificate_binding_type
        certificate_id           = var.custom_domain.certificate_id
        name                     = var.custom_domain.domain_name
      }
    }
  }

  # Secrets cannot be removed from the service once added, attempting to do so will result in an error.
  # Their values may be zeroed, i.e. set to "", but the named secret must persist.
  # This is due to a technical limitation on the service which causes the service to become unmanageable.
  dynamic "secret" {
    for_each = toset(var.secret_variables)
    content {
      name                = lower(secret.value)
      key_vault_secret_id = "https://${var.key_vault_name}.vault.azure.net/secrets/${secret.value}"
      identity            = "${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${local.user_assigned_identity_name}"
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    dynamic "container" {
      for_each = var.container_apps

      content {
        name    = container.key
        image   = "${var.container_registry_login_server}/${coalesce(var.repository_name, var.project)}:${var.image_version}"
        command = container.value.command
        cpu     = container.value.cpu
        memory  = container.value.memory

        dynamic "env" {
          for_each = coalesce(local.env, {})
          content {
            name        = env.key
            secret_name = try(lower(env.value.secret_name), null)
            value       = env.value.value
          }
        }

        # Azure Container Apps health probes allow the Container Apps runtime to regularly inspect the status of your container apps.
        # Checks to see if a replica is ready to handle incoming requests.
        readiness_probe {
          port                    = coalesce(var.health_check_options.port, local.default_app_port)
          transport               = var.health_check_options.transport
          path                    = var.health_check_options.path
          interval_seconds        = var.health_check_options.interval_seconds
          timeout                 = var.health_check_options.timeout
          failure_count_threshold = var.health_check_options.failure_count_threshold
        }

        # Checks if your application is still running and responsive.
        liveness_probe {
          port                    = coalesce(var.health_check_options.port, local.default_app_port)
          transport               = var.health_check_options.transport
          path                    = var.health_check_options.path
          interval_seconds        = var.health_check_options.interval_seconds
          timeout                 = var.health_check_options.timeout # TODO: @sam, make sure that this is align with the puma timeout
          failure_count_threshold = var.health_check_options.failure_count_threshold
        }

        # Checks if your application has successfully started. This check is separate from the liveness probe and executes during the initial startup phase of your application.
        startup_probe {
          port                    = coalesce(var.health_check_options.port, local.default_app_port)
          transport               = var.health_check_options.transport
          path                    = var.health_check_options.path
          interval_seconds        = 120
          timeout                 = 60
          failure_count_threshold = 5
        }
      }
    }
  }

  tags = coalesce(var.tags, local.default_tags)

  # NOTE: This is a temporary fix before managed app environment certificate is enabled in the terraform environment
  # Currently, after container app is created, we manually setup the custom domain in the console together with the enabling of certificate
  lifecycle {
    ignore_changes = [
      ingress.0.custom_domain
    ]
  }
}

# https://learn.microsoft.com/en-us/azure/container-apps/vnet-custom?tabs=bash%2Cazure-cli&pivots=azure-portal
# https://github.com/microsoft/azure-container-apps/issues/345
# When you deploy an internal or an external environment into your own network, a new resource group prefixed with MC_ is created in the Azure subscription where your environment is hosted. This resource group contains infrastructure components managed by the Azure Container Apps platform, and shouldn't be modified. The resource group contains Public IP addresses used specifically for outbound connectivity from your environment and a load balancer.
# Your policy would need to have an exclusion for resource groups that start with "MC_"
# For the moment, the proposed workaround is to add a policy assignment exception for resource group that have the MC_ prefix and _{region} suffix.
resource "azurerm_container_app_environment" "main" {
  name                = coalesce(var.container_app_name, local.default_name)
  location            = var.region
  resource_group_name = var.resource_group_name

  infrastructure_subnet_id       = var.subnet_id
  zone_redundancy_enabled        = var.zone_redundancy_enabled
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  tags                           = coalesce(var.tags, local.default_tags)
}

output "id" {
  value = azurerm_container_app.main.id
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

output "container_app_environment_id" {
  value = azurerm_container_app_environment.main.id
}
