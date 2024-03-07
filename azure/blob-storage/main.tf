# provides a unique namespace in Azure for your data.
resource "azurerm_storage_account" "main" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.region
  account_kind                  = var.account_kind
  account_tier                  = var.account_tier
  account_replication_type      = var.account_replication_type
  public_network_access_enabled = var.public_network_access_enabled
  min_tls_version               = "TLS1_2"
  enable_https_traffic_only     = true
  # default_to_oauth_authentication   = true
  # shared_access_key_enabled         = false
  infrastructure_encryption_enabled = false
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public

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
    versioning_enabled            = var.blob_properties_config.versioning_enabled
    change_feed_enabled           = var.blob_properties_config.change_feed_enabled
    change_feed_retention_in_days = var.blob_properties_config.change_feed_retention_in_days
    last_access_time_enabled      = var.blob_properties_config.last_access_time_enabled
  }

  dynamic "sas_policy" {
    for_each = var.sas_policy == null ? [] : [1]

    content {
      expiration_period = var.sas_policy.expiration_period
      expiration_action = var.sas_policy.expiration_action
    }
  }

  tags = local.default_tags
}

resource "azurerm_storage_container" "main" {
  name                  = var.name
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.container_access_type
}

resource "azurerm_storage_management_policy" "main" {
  count = length(var.lifecycle_rules) > 1 ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.key
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

output "storage_account_id" {
  value = azurerm_storage_account.main.id
}

output "container_id" {
  value = azurerm_storage_container.main.id
}
