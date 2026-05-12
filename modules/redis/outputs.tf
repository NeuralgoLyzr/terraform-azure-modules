output "cluster_id" {
  value       = azurerm_managed_redis_cluster.this.id
  description = "Azure Managed Redis cluster resource ID"
}

output "cluster_name" {
  value       = azurerm_managed_redis_cluster.this.name
  description = "Azure Managed Redis cluster name"
}

output "hostname" {
  value       = azurerm_managed_redis_cluster.this.hostname
  description = "Azure Managed Redis cluster hostname"
}

output "database_id" {
  value       = azurerm_managed_redis_database.this.id
  description = "Azure Managed Redis database resource ID"
}

output "primary_access_key" {
  value       = azurerm_managed_redis_database.this.primary_access_key
  description = "Azure Managed Redis database primary access key"
  sensitive   = true
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
