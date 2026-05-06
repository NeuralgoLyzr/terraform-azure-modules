# ---------------------------------------------------------------------------
# Existing VNet lookup (used when create = false)
# ---------------------------------------------------------------------------
data "azurerm_virtual_network" "existing" {
  count               = var.create ? 0 : 1
  name                = var.existing_vnet_name
  resource_group_name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Virtual Network
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  count               = var.create ? 1 : 0
  name                = local.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = local.all_tags
}

# ---------------------------------------------------------------------------
# Subnets
# ---------------------------------------------------------------------------
resource "azurerm_subnet" "this" {
  for_each             = var.create ? var.subnets : {}
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = [each.value.address_prefix]
  service_endpoints    = each.value.service_endpoints

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# ---------------------------------------------------------------------------
# Network Security Groups (one per subnet except gatewaySubnet)
# ---------------------------------------------------------------------------
resource "azurerm_network_security_group" "this" {
  for_each            = var.create ? local.subnets_with_nsg : {}
  name                = "${local.name_prefix}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.all_tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = var.create ? {
    for item in flatten([
      for subnet_name, rules in var.nsg_rules : [
        for rule in rules : {
          key         = "${subnet_name}-${rule.name}"
          subnet_name = subnet_name
          rule        = rule
        }
      ]
    ]) : item.key => item
  } : {}

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_name].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = var.create ? local.subnets_with_nsg : {}
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

# ---------------------------------------------------------------------------
# NAT Gateway
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "natgw" {
  count               = var.create && var.create_nat_gateway ? 1 : 0
  name                = local.natgw_pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.all_tags
}

resource "azurerm_nat_gateway" "this" {
  count               = var.create && var.create_nat_gateway ? 1 : 0
  name                = local.natgw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"
  tags                = local.all_tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  count                = var.create && var.create_nat_gateway ? 1 : 0
  nat_gateway_id       = azurerm_nat_gateway.this[0].id
  public_ip_address_id = azurerm_public_ip.natgw[0].id
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each       = var.create && var.create_nat_gateway ? toset(var.nat_gateway_subnets) : toset([])
  subnet_id      = azurerm_subnet.this[each.key].id
  nat_gateway_id = azurerm_nat_gateway.this[0].id
}
