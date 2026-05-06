# ---------------------------------------------------------------------------
# Bring-your-own-resource support
# ---------------------------------------------------------------------------
variable "create" {
  type        = bool
  description = "Set to false to use an existing Application Gateway"
  default     = true
}

variable "existing_app_gateway_id" {
  type        = string
  description = "Resource ID of an existing Application Gateway (only used when create = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Identity / naming inputs
# ---------------------------------------------------------------------------
variable "company" {
  type        = string
  description = "Company or org short name used in resource naming"
}

variable "product" {
  type        = string
  description = "Product or team name used in resource naming"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

# ---------------------------------------------------------------------------
# Application Gateway config
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID for the Application Gateway (appGatewaySubnet)"
}

variable "sku_name" {
  type        = string
  description = "Application Gateway SKU name"
  default     = "WAF_v2"
  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "sku_name must be Standard_v2 or WAF_v2."
  }
}

variable "capacity" {
  type        = number
  description = "Number of Application Gateway instances (min 1)"
  default     = 1
}

variable "enable_waf" {
  type        = bool
  description = "Enable WAF policy (requires WAF_v2 SKU)"
  default     = true
}

variable "waf_mode" {
  type        = string
  description = "WAF mode: Detection or Prevention"
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "waf_mode must be Detection or Prevention."
  }
}

variable "managed_identity_id" {
  type        = string
  description = "User-assigned managed identity ID for Key Vault SSL cert access"
  default     = ""
}

variable "ssl_certificate" {
  type = object({
    name                = string
    key_vault_secret_id = string
  })
  description = "SSL certificate config referencing a Key Vault secret"
  default     = null
}

variable "backend_pools" {
  type = map(object({
    fqdns        = optional(list(string), [])
    ip_addresses = optional(list(string), [])
  }))
  description = "Map of backend pool name to config"
  default = {
    aks-backend = {
      fqdns        = []
      ip_addresses = []
    }
  }
}

variable "http_listeners" {
  type = map(object({
    frontend_ip_configuration_name = optional(string, "public")
    port                           = optional(number, 443)
    protocol                       = optional(string, "Https")
    ssl_certificate_name           = optional(string, "")
    host_name                      = optional(string, "")
  }))
  description = "Map of HTTP listener name to config"
  default = {
    https-listener = {
      frontend_ip_configuration_name = "public"
      port                           = 443
      protocol                       = "Https"
      ssl_certificate_name           = ""
      host_name                      = ""
    }
  }
}

variable "request_routing_rules" {
  type = map(object({
    rule_type                  = optional(string, "Basic")
    http_listener_name         = string
    backend_address_pool_name  = string
    backend_http_settings_name = string
    priority                   = number
  }))
  description = "Map of routing rule name to config"
  default = {
    default-rule = {
      rule_type                  = "Basic"
      http_listener_name         = "https-listener"
      backend_address_pool_name  = "aks-backend"
      backend_http_settings_name = "aks-http-settings"
      priority                   = 100
    }
  }
}

variable "backend_http_settings" {
  type = map(object({
    port                  = optional(number, 80)
    protocol              = optional(string, "Http")
    request_timeout       = optional(number, 60)
    pick_host_name_from_backend = optional(bool, false)
  }))
  description = "Map of backend HTTP settings name to config"
  default = {
    aks-http-settings = {
      port                        = 80
      protocol                    = "Http"
      request_timeout             = 60
      pick_host_name_from_backend = false
    }
  }
}

# ---------------------------------------------------------------------------
# Tagging
# ---------------------------------------------------------------------------
variable "owner" {
  type        = string
  description = "Team or person responsible for these resources"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
}

variable "terraform_repo" {
  type        = string
  description = "Name of the Terraform repo managing these resources"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged on top of mandatory tags"
  default     = {}
}
