output "vnet_id" {
  value       = var.create ? azurerm_virtual_network.this[0].id : data.azurerm_virtual_network.existing[0].id
  description = "Virtual Network resource ID"
}

output "vnet_name" {
  value       = var.create ? azurerm_virtual_network.this[0].name : data.azurerm_virtual_network.existing[0].name
  description = "Virtual Network name"
}

output "subnet_ids" {
  value       = var.create ? { for k, v in azurerm_subnet.this : k => v.id } : {}
  description = "Map of subnet name to subnet ID"
}

output "nsg_ids" {
  value       = var.create ? { for k, v in azurerm_network_security_group.this : k => v.id } : {}
  description = "Map of subnet name to NSG ID"
}

output "nat_gateway_id" {
  value       = var.create && var.create_nat_gateway ? azurerm_nat_gateway.this[0].id : ""
  description = "NAT Gateway resource ID (empty if not created)"
}

output "nat_gateway_public_ip" {
  value       = var.create && var.create_nat_gateway ? azurerm_public_ip.natgw[0].ip_address : ""
  description = "Static public IP of the NAT Gateway (empty if not created)"
}
