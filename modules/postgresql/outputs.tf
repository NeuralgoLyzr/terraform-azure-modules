output "server_id" {
  value       = azurerm_postgresql_flexible_server.this.id
  description = "PostgreSQL Flexible Server resource ID"
}

output "server_name" {
  value       = azurerm_postgresql_flexible_server.this.name
  description = "PostgreSQL Flexible Server name"
}

output "fqdn" {
  value       = azurerm_postgresql_flexible_server.this.fqdn
  description = "Fully qualified domain name of the server"
}

output "admin_username" {
  value       = azurerm_postgresql_flexible_server.this.administrator_login
  description = "Administrator login name"
}

output "admin_password" {
  value       = random_password.admin.result
  description = "Generated administrator password"
  sensitive   = true
}

output "private_dns_zone_id" {
  value       = local.private_dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}

output "database_names" {
  value       = keys(azurerm_postgresql_flexible_server_database.this)
  description = "List of created database names"
}
