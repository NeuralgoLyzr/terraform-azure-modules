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
  description = "Primary Azure region (e.g. westeurope)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to deploy into"
}

# ---------------------------------------------------------------------------
# DocumentDB cluster configuration
# ---------------------------------------------------------------------------
variable "administrator_username" {
  type        = string
  description = "Admin username for the DocumentDB cluster"
}

variable "administrator_password" {
  type        = string
  sensitive   = true
  description = "Admin password for the DocumentDB cluster"
}

variable "compute_tier" {
  type        = string
  description = "vCore compute tier — M10 (2 vCores), M20 (4), M30 (8), M40 (16), etc."
  default     = "M10"
}

variable "high_availability_mode" {
  type        = string
  description = "High availability mode — Disabled or ZoneRedundantPreferred"
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "ZoneRedundantPreferred"], var.high_availability_mode)
    error_message = "high_availability_mode must be Disabled or ZoneRedundantPreferred."
  }
}

variable "storage_size_in_gb" {
  type        = number
  description = "Storage size in GB per shard"
  default     = 32
}

variable "mongo_version" {
  type        = string
  description = "MongoDB compatibility version (5.0, 6.0, 7.0, 8.0)"
  default     = "7.0"
}

# ---------------------------------------------------------------------------
# Public network access
# ---------------------------------------------------------------------------
variable "public_network_access" {
  type        = string
  description = "Enable public network access — Enabled or Disabled."
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "public_network_access must be Enabled or Disabled."
  }
}

variable "firewall_ip_rules" {
  type        = list(string)
  description = "CIDR ranges allowed when public_network_access = Enabled. Use [\"0.0.0.0/0\"] to allow all."
  default     = []
}

# ---------------------------------------------------------------------------
# Networking (private endpoint)
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint NIC"
}

variable "vnet_id" {
  type        = string
  description = "VNet ID — used to link the private DNS zone"
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Set to false if privatelink.mongocluster.cosmos.azure.com DNS zone already exists"
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
  description = "Key Vault ID to store the primary connection string (leave empty to skip)"
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
