# ---------------------------------------------------------------------------
# Public IP for Application Gateway
# ---------------------------------------------------------------------------
resource "azurerm_public_ip" "agw" {
  count               = var.create ? 1 : 0
  name                = local.agw_pip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.all_tags
}

# ---------------------------------------------------------------------------
# WAF Policy
# ---------------------------------------------------------------------------
resource "azurerm_web_application_firewall_policy" "this" {
  count               = var.create && var.enable_waf ? 1 : 0
  name                = local.waf_policy
  location            = var.location
  resource_group_name = var.resource_group_name

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# Application Gateway
# ---------------------------------------------------------------------------
resource "azurerm_application_gateway" "this" {
  count               = var.create ? 1 : 0
  name                = local.agw_name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = var.enable_waf ? azurerm_web_application_firewall_policy.this[0].id : null

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = var.capacity
  }

  dynamic "identity" {
    for_each = var.managed_identity_id != "" ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.managed_identity_id]
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "public"
    public_ip_address_id = azurerm_public_ip.agw[0].id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  frontend_port {
    name = "port-80"
    port = 80
  }

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificate != null ? [var.ssl_certificate] : []
    content {
      name                = ssl_certificate.value.name
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_pools
    content {
      name         = backend_address_pool.key
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = backend_http_settings.key
      cookie_based_affinity               = "Disabled"
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = http_listener.key
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = "port-${http_listener.value.port}"
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = http_listener.value.ssl_certificate_name != "" ? http_listener.value.ssl_certificate_name : null
      host_name                      = http_listener.value.host_name != "" ? http_listener.value.host_name : null
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                       = request_routing_rule.key
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                   = request_routing_rule.value.priority
    }
  }

  tags = local.all_tags

  lifecycle {
    # AGIC manages backend pool membership — ignore drift from AKS
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      probe,
      tags["modified-by-agic"]
    ]
  }
}
