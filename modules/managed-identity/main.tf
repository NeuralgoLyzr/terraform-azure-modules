# ---------------------------------------------------------------------------
# User-assigned managed identity
# ---------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "this" {
  name                = local.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.all_tags
}

# ---------------------------------------------------------------------------
# RBAC role assignments
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  for_each = {
    for idx, ra in var.role_assignments : "${ra.role_definition_name}-${ra.scope}" => ra
  }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
  description          = each.value.description != "" ? each.value.description : null
}
