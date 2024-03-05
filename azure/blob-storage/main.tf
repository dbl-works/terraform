# provides a unique namespace in Azure for your data.
resource "azurerm_storage_account" "main" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.region
  account_kind                    = var.account_kind
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  public_network_access_enabled   = var.public_network_access_enabled
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public

  dynamic "identity" {
    for_each = length(var.user_assigned_identity_ids) > 1 ? [1] : []

    content {
      type         = "UserAssigned"
      identity_ids = var.user_assigned_identity_ids
    }
  }

  dynamic "static_website" {
    for_each = var.static_website == null ? [] : [1]

    content {
      index_document     = var.static_website.index_document
      error_404_document = var.static_website.error_404_document
    }
  }

  blob_properties {
    cors_rule {
      allowed_headers    = var.cors_config.allowed_headers
      allowed_methods    = var.cors_config.allowed_methods
      allowed_origins    = var.cors_config.allowed_origins
      exposed_headers    = var.cors_config.exposed_headers
      max_age_in_seconds = var.cors_config.max_age_in_seconds
    }
    versioning_enabled = var.versioning_enabled
  }

  tags = local.default_tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.container_access_type
}

resource "azurerm_storage_management_policy" "main" {
  storage_account_id = azurerm_storage_account.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.value.name
      enabled = true
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = rule.value.blob_types
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.tier_to_cool_after_days_since_modification_greater_than
          tier_to_archive_after_days_since_modification_greater_than = rule.value.tier_to_archive_after_days_since_modification_greater_than
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days_since_modification_greater_than
        }
      }
    }
  }
}

output "primary_web_host" {
  value = azurerm_storage_account.main.primary_web_host
}

output "id" {
  value = azurerm_storage_account.main.id
}
