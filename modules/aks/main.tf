# ---------------------------------------------------------------------------
# AKS Cluster
# ---------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = local.dns_prefix
  kubernetes_version  = var.kubernetes_version
  sku_tier            = var.sku_tier

  # System-assigned identity — AGIC and kubelet use their own identities
  identity {
    type = "SystemAssigned"
  }

  # System node pool
  default_node_pool {
    name                = "system"
    vm_size             = var.node_vm_size
    os_disk_size_gb     = var.os_disk_size_gb
    vnet_subnet_id      = var.subnet_id
    auto_scaling_enabled = var.enable_auto_scaling
    node_count          = var.enable_auto_scaling ? null : var.node_count
    min_count           = var.enable_auto_scaling ? var.min_node_count : null
    max_count           = var.enable_auto_scaling ? var.max_node_count : null

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Azure CNI networking — pods get IPs from the VNet subnet
  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }

  # OIDC issuer + Workload Identity — required for pod-level Azure auth
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # AGIC — connects to the existing Application Gateway
  ingress_application_gateway {
    gateway_id = var.app_gateway_id
  }

  # Key Vault CSI secrets provider
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []
    content {
      secret_rotation_enabled = true
    }
  }

  tags = local.all_tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      kubernetes_version,
    ]
  }
}

# ---------------------------------------------------------------------------
# AcrPull — allows AKS nodes to pull images from ACR
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "acr_pull" {
  count                = var.acr_id != "" ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  description          = "AKS kubelet identity pull access to ACR"
}

# ---------------------------------------------------------------------------
# Additional RBAC role assignments
# ---------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  for_each = {
    for ra in var.role_assignments : "${ra.role_definition_name}-${ra.principal_id}" => ra
  }

  scope                = azurerm_kubernetes_cluster.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
  description          = each.value.description != "" ? each.value.description : null
}
