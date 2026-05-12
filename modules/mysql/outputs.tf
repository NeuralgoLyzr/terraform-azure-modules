output "server_id" {
  value       = azurerm_mysql_flexible_server.this.id
  description = "MySQL Flexible Server resource ID"
}

output "server_name" {
  value       = azurerm_mysql_flexible_server.this.name
  description = "MySQL Flexible Server name"
}

output "fqdn" {
  value       = azurerm_mysql_flexible_server.this.fqdn
  description = "MySQL Flexible Server fully qualified domain name"
}

output "database_name" {
  value       = azurerm_mysql_flexible_server_database.this.name
  description = "Database name"
}

output "admin_username" {
  value       = azurerm_mysql_flexible_server.this.administrator_login
  description = "Temporary admin username"
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
