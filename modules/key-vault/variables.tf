# ---------------------------------------------------------------------------
# Bring-your-own-resource support
# ---------------------------------------------------------------------------
variable "create" {
  type        = bool
  description = "Set to false to use an existing Key Vault instead of creating one"
  default     = true
}

variable "existing_key_vault_name" {
  type        = string
  description = "Name of an existing Key Vault (only used when create = false)"
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
# Key Vault configuration
# ---------------------------------------------------------------------------
variable "sku_name" {
  type        = string
  description = "SKU for the Key Vault (standard or premium)"
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "sku_name must be standard or premium."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain soft-deleted objects (7–90)"
  default     = 7
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "enable_purge_protection" {
  type        = bool
  description = "Enable purge protection — recommended for prod, prevents permanent deletion for retention period"
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Allow Azure Disk Encryption to retrieve secrets"
  default     = false
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Allow Azure VMs to retrieve certificates stored as secrets"
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Allow Azure Resource Manager to retrieve secrets for template deployments"
  default     = false
}

# ---------------------------------------------------------------------------
# Network access control
# ---------------------------------------------------------------------------
variable "network_acls_default_action" {
  type        = string
  description = "Default action for network ACLs (Allow or Deny)"
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls_default_action)
    error_message = "network_acls_default_action must be Allow or Deny."
  }
}

variable "network_acls_bypass" {
  type        = string
  description = "Services allowed to bypass network ACLs (AzureServices or None)"
  default     = "AzureServices"
}

variable "network_acls_ip_rules" {
  type        = list(string)
  description = "List of IP addresses or CIDR ranges allowed to access Key Vault"
  default     = []
}

variable "network_acls_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs allowed to access Key Vault via service endpoints"
  default     = []
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
  description = "List of RBAC role assignments on this Key Vault (RBAC authorization must be enabled)"
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
