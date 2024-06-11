terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # Only version >= 3.98.0 support key_vault_secret_id and identity fields in secret block
      version = ">= 3.98.0"
    }
  }
  required_version = ">= 1.0"
}
