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
# PostgreSQL server configuration
# ---------------------------------------------------------------------------
variable "postgres_version" {
  type        = string
  description = "PostgreSQL major version"
  default     = "16"
}

variable "sku_name" {
  type        = string
  description = "SKU for the flexible server (e.g. Standard_B1ms, Standard_D2s_v3)"
  default     = "Standard_B1ms"
}

variable "storage_mb" {
  type        = number
  description = "Storage size in MB (32768 = 32 GB)"
  default     = 32768
}

variable "backup_retention_days" {
  type        = number
  description = "Backup retention period in days (7–35)"
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "backup_retention_days must be between 7 and 35."
  }
}

variable "geo_redundant_backup" {
  type        = bool
  description = "Enable geo-redundant backups (not supported on Burstable SKUs)"
  default     = false
}

variable "availability_zone" {
  type        = string
  description = "Availability zone for the primary server (1, 2, or 3)"
  default     = "1"
}

variable "enable_high_availability" {
  type        = bool
  description = "Enable zone-redundant high availability (requires non-Burstable SKU)"
  default     = false
}

variable "standby_availability_zone" {
  type        = string
  description = "Availability zone for the HA standby replica"
  default     = "2"
}

# ---------------------------------------------------------------------------
# Admin credentials
# ---------------------------------------------------------------------------
variable "admin_username" {
  type        = string
  description = "Administrator login name"
  default     = "psqladmin"
}

# ---------------------------------------------------------------------------
# Networking (VNet integration)
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "ID of the delegated subnet for PostgreSQL VNet integration (dataSubnet)"
}

variable "vnet_id" {
  type        = string
  description = "ID of the VNet — used to link the private DNS zone"
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Set to false if privatelink.postgres.database.azure.com DNS zone already exists"
  default     = true
}

variable "existing_private_dns_zone_id" {
  type        = string
  description = "ID of an existing private DNS zone (only used when create_private_dns_zone = false)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Databases
# ---------------------------------------------------------------------------
variable "databases" {
  type        = list(string)
  description = "List of database names to create on the server"
  default     = ["lyzrdb"]
}

# ---------------------------------------------------------------------------
# Key Vault integration (optional — write password as secret)
# ---------------------------------------------------------------------------
variable "key_vault_id" {
  type        = string
  description = "Key Vault ID to store the generated admin password (leave empty to skip)"
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
