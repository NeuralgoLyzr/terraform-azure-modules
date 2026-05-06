output "private_endpoint_id" {
  value       = azurerm_private_endpoint.this.id
  description = "Private Endpoint resource ID"
}

output "private_ip_address" {
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
  description = "Private IP address assigned to the endpoint"
}

output "dns_zone_id" {
  value       = local.dns_zone_id
  description = "Private DNS Zone resource ID"
}

output "dns_zone_name" {
  value       = var.private_dns_zone_name
  description = "Private DNS Zone name"
}
