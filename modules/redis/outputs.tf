output "cluster_id" {
  value       = azurerm_redis_enterprise_cluster.this.id
  description = "Redis Enterprise cluster resource ID"
}

output "cluster_name" {
  value       = azurerm_redis_enterprise_cluster.this.name
  description = "Redis Enterprise cluster name"
}

output "hostname" {
  value       = azurerm_redis_enterprise_cluster.this.hostname
  description = "Redis Enterprise cluster hostname"
}

output "database_id" {
  value       = azurerm_redis_enterprise_database.this.id
  description = "Redis Enterprise database resource ID"
}

output "primary_access_key" {
  value       = azurerm_redis_enterprise_database.this.primary_access_key
  description = "Redis Enterprise database primary access key"
  sensitive   = true
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
