output "account_id" {
  value       = azurerm_cosmosdb_account.this.id
  description = "CosmosDB account resource ID"
}

output "account_name" {
  value       = azurerm_cosmosdb_account.this.name
  description = "CosmosDB account name"
}

output "endpoint" {
  value       = azurerm_cosmosdb_account.this.endpoint
  description = "CosmosDB account endpoint"
}

output "primary_key" {
  value       = azurerm_cosmosdb_account.this.primary_key
  description = "CosmosDB primary master key"
  sensitive   = true
}

output "database_names" {
  value       = keys(azurerm_cosmosdb_mongo_database.this)
  description = "List of created MongoDB database names"
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
