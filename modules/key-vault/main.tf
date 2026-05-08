data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Existing Key Vault lookup (used when create = false)
# ---------------------------------------------------------------------------
data "azurerm_key_vault" "existing" {
  count               = var.create ? 0 : 1
  name                = var.existing_key_vault_name
  resource_group_name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Key Vault
# ---------------------------------------------------------------------------
resource "azurerm_key_vault" "this" {
  count               = var.create ? 1 : 0
  name                = local.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                        = var.sku_name
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.enable_purge_protection
  enable_rbac_authorization       = true
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_template_deployment = var.enabled_for_template_deployment

  network_acls {
    default_action             = var.network_acls_default_action
    bypass                     = var.network_acls_bypass
    ip_rules                   = var.network_acls_ip_rules
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# RBAC role assignments
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  for_each = var.create ? {
    for idx, ra in var.role_assignments : "${ra.role_definition_name}-${ra.principal_id}" => ra
  } : {}

  scope                = azurerm_key_vault.this[0].id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = each.value.description != "" ? each.value.description : null
}
