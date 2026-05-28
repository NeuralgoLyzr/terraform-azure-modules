# ---------------------------------------------------------------------------
# Bring-your-own-resource support
# ---------------------------------------------------------------------------
variable "create" {
  type        = bool
  description = "Set to false to use an existing Container Registry instead of creating one"
  default     = true
}

variable "existing_registry_name" {
  type        = string
  description = "Name of an existing Container Registry (only used when create = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Identity / naming inputs
# ---------------------------------------------------------------------------
variable "company" {
  type        = string
  description = "Company or org short name used in resource naming (e.g. lyzr)"
}

variable "product" {
  type        = string
  description = "Product or team name used in resource naming (e.g. studio)"
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
  description = "Azure region (e.g. westeurope)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

# ---------------------------------------------------------------------------
# Container Registry configuration
# ---------------------------------------------------------------------------
variable "sku" {
  type        = string
  description = "SKU for the Container Registry (Basic, Standard, or Premium)"
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Enable the admin user for the registry — use only when needed, prefer managed identity"
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow public network access to the registry"
  default     = true
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = "Allow unauthenticated pulls — requires Standard or Premium SKU"
  default     = false
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy — requires Premium SKU"
  default     = false
}

# ---------------------------------------------------------------------------
# Networking (private endpoint — requires Premium SKU)
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint NIC (leave empty to skip private endpoint)"
  default     = ""
}

variable "vnet_id" {
  type        = string
  description = "VNet ID — used to link the private DNS zone (leave empty to skip private endpoint)"
  default     = ""
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Set to false if privatelink.azurecr.io DNS zone already exists"
  default     = true
}

variable "existing_private_dns_zone_id" {
  type        = string
  description = "ID of an existing private DNS zone (only used when create_private_dns_zone = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Key Vault integration (optional — store admin credentials)
# ---------------------------------------------------------------------------
variable "key_vault_id" {
  type        = string
  description = "Key Vault ID to store admin credentials when admin_enabled = true (leave empty to skip)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Role assignments
# ---------------------------------------------------------------------------
variable "role_assignments" {
  type = list(object({
    principal_id         = string
    role_definition_name = string
    description          = optional(string, "")
  }))
  description = "List of RBAC role assignments on this Container Registry"
  default     = []
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
