output "vm_id" {
  value       = azurerm_linux_virtual_machine.this.id
  description = "VM resource ID"
}

output "vm_name" {
  value       = azurerm_linux_virtual_machine.this.name
  description = "VM name"
}

output "private_ip_address" {
  value       = azurerm_network_interface.this.private_ip_address
  description = "Static private IP assigned to the VM"
}

output "nsg_id" {
  value       = azurerm_network_security_group.this.id
  description = "NSG resource ID"
}

output "nic_id" {
  value       = azurerm_network_interface.this.id
  description = "NIC resource ID"
}

output "data_disk_id" {
  value       = var.data_disk_size_gb > 0 ? azurerm_managed_disk.data[0].id : null
  description = "Data disk resource ID (null if no data disk)"
}
