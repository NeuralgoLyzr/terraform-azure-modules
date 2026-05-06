# ---------------------------------------------------------------------------
# Private DNS Zone
# ---------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "this" {
  count               = var.create_dns_zone ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = local.all_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = local.dns_zone_link
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = local.all_tags

  depends_on = [azurerm_private_dns_zone.this]
}

# ---------------------------------------------------------------------------
# Private Endpoint
# ---------------------------------------------------------------------------
resource "azurerm_private_endpoint" "this" {
  name                = local.pe_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = local.all_tags

  private_service_connection {
    name                           = "${local.pe_name}-connection"
    private_connection_resource_id = var.resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${local.pe_name}-dns-group"
    private_dns_zone_ids = [local.dns_zone_id]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}
