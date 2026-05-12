output "cluster_id" {
  value       = azapi_resource.redis_cluster.id
  description = "Redis cluster resource ID"
}

output "cluster_name" {
  value       = azapi_resource.redis_cluster.name
  description = "Redis cluster name"
}

output "hostname" {
  value       = azapi_resource.redis_cluster.output.properties.hostName
  description = "Redis cluster hostname"
}

output "database_id" {
  value       = azapi_resource.redis_database.id
  description = "Redis database resource ID"
}

output "primary_access_key" {
  value       = data.azapi_resource_action.redis_keys.output.primaryKey
  description = "Redis database primary access key"
  sensitive   = true
}

output "private_dns_zone_id" {
  value       = module.private_endpoint.dns_zone_id
  description = "Private DNS zone ID — pass to other modules sharing this DNS zone"
}
