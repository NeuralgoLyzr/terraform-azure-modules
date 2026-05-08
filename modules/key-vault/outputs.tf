output "key_vault_id" {
  value       = var.create ? azurerm_key_vault.this[0].id : data.azurerm_key_vault.existing[0].id
  description = "Key Vault resource ID"
}

output "key_vault_name" {
  value       = var.create ? azurerm_key_vault.this[0].name : data.azurerm_key_vault.existing[0].name
  description = "Key Vault name"
}

output "key_vault_uri" {
  value       = var.create ? azurerm_key_vault.this[0].vault_uri : data.azurerm_key_vault.existing[0].vault_uri
  description = "Key Vault URI (e.g. https://<name>.vault.azure.net/)"
}

output "tenant_id" {
  value       = data.azurerm_client_config.current.tenant_id
  description = "Azure tenant ID"
}
