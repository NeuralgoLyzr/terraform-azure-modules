output "cluster_id" {
  value       = azurerm_mongo_cluster.this.id
  description = "DocumentDB cluster resource ID"
}

output "cluster_name" {
  value       = azurerm_mongo_cluster.this.name
  description = "DocumentDB cluster name"
}

output "connection_string" {
  value       = azurerm_mongo_cluster.this.connection_strings[0].value
  description = "Primary MongoDB connection string"
  sensitive   = true
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
