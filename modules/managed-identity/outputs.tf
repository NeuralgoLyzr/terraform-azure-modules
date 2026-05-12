output "identity_id" {
  value       = azurerm_user_assigned_identity.this.id
  description = "Resource ID of the user-assigned managed identity"
}

output "principal_id" {
  value       = azurerm_user_assigned_identity.this.principal_id
  description = "Principal (object) ID of the managed identity — used for AAD admin and RBAC"
}

output "client_id" {
  value       = azurerm_user_assigned_identity.this.client_id
  description = "Client ID of the managed identity — used by workloads for authentication"
}

output "name" {
  value       = azurerm_user_assigned_identity.this.name
  description = "Name of the managed identity"
}
