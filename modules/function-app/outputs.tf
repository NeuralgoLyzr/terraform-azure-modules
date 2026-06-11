output "storage_account_name" {
  value       = azurerm_storage_account.this.name
  description = "Name of the shared storage account used by the Function Apps"
}

output "service_plan_id" {
  value       = azurerm_service_plan.this.id
  description = "Resource ID of the App Service Plan"
}

output "function_app_names" {
  value       = { for k, fa in azurerm_linux_function_app.this : k => fa.name }
  description = "Map of function app key to resource name"
}

output "function_app_ids" {
  value       = { for k, fa in azurerm_linux_function_app.this : k => fa.id }
  description = "Map of function app key to resource ID"
}

output "function_app_default_hostnames" {
  value       = { for k, fa in azurerm_linux_function_app.this : k => fa.default_hostname }
  description = "Map of function app key to default hostname"
}
