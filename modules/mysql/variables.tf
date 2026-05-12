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
# MySQL server configuration
# ---------------------------------------------------------------------------
variable "mysql_version" {
  type        = string
  description = "MySQL version"
  default     = "8.0.21"
}

variable "sku_name" {
  type        = string
  description = "SKU for the flexible server (e.g. B_Standard_B1ms, GP_Standard_D2ds_v4)"
  default     = "B_Standard_B1ms"
}

variable "storage_size_gb" {
  type        = number
  description = "Storage size in GB"
  default     = 20
}

variable "iops" {
  type        = number
  description = "Storage IOPS"
  default     = 360
}

variable "auto_grow_enabled" {
  type        = bool
  description = "Enable storage auto grow"
  default     = true
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention period in days (1–35)"
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 1 and 35."
  }
}

variable "geo_redundant_backup_enabled" {
  type        = bool
  description = "Enable geo-redundant backups"
  default     = false
}

variable "high_availability_mode" {
  type        = string
  description = "High availability mode: Disabled or ZoneRedundant"
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "ZoneRedundant"], var.high_availability_mode)
    error_message = "high_availability_mode must be Disabled or ZoneRedundant."
  }
}

# ---------------------------------------------------------------------------
# Admin credentials
# ---------------------------------------------------------------------------
variable "admin_username" {
  type        = string
  description = "Temporary administrator login (replaced by Entra ID admin post-deploy)"
  default     = "tempadmin"
}

# ---------------------------------------------------------------------------
# Entra ID (AAD) administrator — managed identity
# ---------------------------------------------------------------------------
variable "managed_identity_id" {
  type        = string
  description = "Resource ID of the user-assigned managed identity used as AAD admin"
}

variable "managed_identity_principal_id" {
  type        = string
  description = "Principal (object) ID of the managed identity — used as AAD admin SID"
}

variable "managed_identity_name" {
  type        = string
  description = "Name of the managed identity — used as AAD admin login"
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------
variable "database_name" {
  type        = string
  description = "Name of the database to create"
  default     = "lyzr"
}

# ---------------------------------------------------------------------------
# Networking (private endpoint)
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint NIC (privateEndpointSubnet)"
}

variable "vnet_id" {
  type        = string
  description = "VNet ID — used to link the private DNS zone"
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Set to false if privatelink.mysql.database.azure.com DNS zone already exists"
  default     = true
}

variable "existing_private_dns_zone_id" {
  type        = string
  description = "ID of an existing private DNS zone (only used when create_private_dns_zone = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Key Vault integration (optional)
# ---------------------------------------------------------------------------
variable "key_vault_id" {
  type        = string
  description = "Key Vault ID to store the temp admin password (leave empty to skip)"
  default     = ""
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
