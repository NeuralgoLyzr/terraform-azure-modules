output "registry_id" {
  value       = var.create ? azurerm_container_registry.this[0].id : data.azurerm_container_registry.existing[0].id
  description = "Container Registry resource ID"
}

output "registry_name" {
  value       = var.create ? azurerm_container_registry.this[0].name : data.azurerm_container_registry.existing[0].name
  description = "Container Registry name"
}

output "login_server" {
  value       = var.create ? azurerm_container_registry.this[0].login_server : data.azurerm_container_registry.existing[0].login_server
  description = "Container Registry login server URL (e.g. <name>.azurecr.io)"
}

output "admin_username" {
  value       = var.create && var.admin_enabled ? azurerm_container_registry.this[0].admin_username : null
  description = "Admin username — only populated when admin_enabled = true"
  sensitive   = true
}

output "admin_password" {
  value       = var.create && var.admin_enabled ? azurerm_container_registry.this[0].admin_password : null
  description = "Admin password — only populated when admin_enabled = true"
  sensitive   = true
}
