output "app_gateway_id" {
  value       = var.create ? azurerm_application_gateway.this[0].id : var.existing_app_gateway_id
  description = "Application Gateway resource ID"
}

output "app_gateway_name" {
  value       = var.create ? azurerm_application_gateway.this[0].name : ""
  description = "Application Gateway name"
}

output "public_ip_address" {
  value       = var.create ? azurerm_public_ip.agw[0].ip_address : ""
  description = "Public IP address of the Application Gateway"
}

output "public_ip_id" {
  value       = var.create ? azurerm_public_ip.agw[0].id : ""
  description = "Public IP resource ID"
}

output "waf_policy_id" {
  value       = var.create && var.enable_waf ? azurerm_web_application_firewall_policy.this[0].id : ""
  description = "WAF policy resource ID (empty if WAF not enabled)"
}
