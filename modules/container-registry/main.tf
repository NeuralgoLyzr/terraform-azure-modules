# ---------------------------------------------------------------------------
# Existing registry lookup (used when create = false)
# ---------------------------------------------------------------------------
data "azurerm_container_registry" "existing" {
  count               = var.create ? 0 : 1
  name                = var.existing_registry_name
  resource_group_name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Container Registry
# ---------------------------------------------------------------------------
resource "azurerm_container_registry" "this" {
  count               = var.create ? 1 : 0
  name                = local.registry_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  anonymous_pull_enabled        = var.anonymous_pull_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# Private Endpoint (optional — requires Premium SKU and subnet_id/vnet_id set)
# ---------------------------------------------------------------------------
module "private_endpoint" {
  count  = var.create && var.subnet_id != "" && var.vnet_id != "" ? 1 : 0
  source = "../private-endpoint"

  company             = var.company
  product             = var.product
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  owner               = var.owner
  cost_center         = var.cost_center
  terraform_repo      = var.terraform_repo

  name              = "acr"
  subnet_id         = var.subnet_id
  resource_id       = azurerm_container_registry.this[0].id
  subresource_names = ["registry"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.azurecr.io"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store admin credentials in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "acr_admin_username" {
  count        = var.create && var.admin_enabled && var.key_vault_id != "" ? 1 : 0
  name         = "ACR-ADMIN-USERNAME"
  value        = azurerm_container_registry.this[0].admin_username
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "acr_admin_password" {
  count        = var.create && var.admin_enabled && var.key_vault_id != "" ? 1 : 0
  name         = "ACR-ADMIN-PASSWORD"
  value        = azurerm_container_registry.this[0].admin_password
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "acr_login_server" {
  count        = var.create && var.key_vault_id != "" ? 1 : 0
  name         = "ACR-LOGIN-SERVER"
  value        = azurerm_container_registry.this[0].login_server
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# RBAC role assignments
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  for_each = var.create ? {
    for idx, ra in var.role_assignments : "${ra.role_definition_name}-${ra.principal_id}" => ra
  } : {}

  scope                = azurerm_container_registry.this[0].id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = each.value.description != "" ? each.value.description : null
}
