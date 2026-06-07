# ── NSG ─────────────────────────────────────────────────────────────────────
resource "azurerm_network_security_group" "this" {
  name                = "${local.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.all_tags
}

resource "azurerm_network_security_rule" "inbound" {
  for_each = { for r in var.nsg_inbound_rules : r.name => r }

  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name

  name                       = each.value.name
  priority                   = each.value.priority
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = each.value.destination_port_range
  source_address_prefix      = each.value.source_address_prefix
  destination_address_prefix = "*"
}

# SSH from within VNet always allowed
resource "azurerm_network_security_rule" "ssh" {
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name

  name                       = "AllowSSHFromVNet"
  priority                   = 900
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "VirtualNetwork"
  destination_address_prefix = "*"
}

# ── NIC ──────────────────────────────────────────────────────────────────────
resource "azurerm_network_interface" "this" {
  name                = "${local.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.all_tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# ── VM ───────────────────────────────────────────────────────────────────────
resource "azurerm_linux_virtual_machine" "this" {
  name                            = local.vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  tags                            = local.all_tags

  network_interface_ids = [azurerm_network_interface.this.id]

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# ── Data disk (optional) ─────────────────────────────────────────────────────
resource "azurerm_managed_disk" "data" {
  count                = var.data_disk_size_gb > 0 ? 1 : 0
  name                 = "${local.vm_name}-data-disk"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = var.data_disk_storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  tags                 = local.all_tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.data_disk_size_gb > 0 ? 1 : 0
  managed_disk_id    = azurerm_managed_disk.data[0].id
  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  lun                = 0
  caching            = "ReadWrite"
}

# ── Custom script extension (optional) ───────────────────────────────────────
resource "azurerm_virtual_machine_extension" "setup" {
  count                = var.custom_script_command != "" ? 1 : 0
  name                 = "${local.vm_name}-setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.this.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  tags                 = local.all_tags

  protected_settings = jsonencode({
    commandToExecute = var.custom_script_command
  })

  depends_on = [azurerm_virtual_machine_data_disk_attachment.data]
}
