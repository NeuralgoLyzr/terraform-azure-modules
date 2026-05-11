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
# CosmosDB account configuration
# ---------------------------------------------------------------------------
variable "mongo_server_version" {
  type        = string
  description = "MongoDB server version"
  default     = "4.2"
}

variable "consistency_level" {
  type        = string
  description = "Default consistency level (Eventual, Session, BoundedStaleness, Strong, ConsistentPrefix)"
  default     = "Strong"
  validation {
    condition     = contains(["Eventual", "Session", "BoundedStaleness", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "consistency_level must be one of: Eventual, Session, BoundedStaleness, Strong, ConsistentPrefix."
  }
}

variable "secondary_location" {
  type        = string
  description = "Secondary Azure region for read replica. Leave empty to disable geo-redundancy."
  default     = "northeurope"
}

variable "backup_tier" {
  type        = string
  description = "Continuous backup tier (Continuous7Days or Continuous30Days)"
  default     = "Continuous7Days"
  validation {
    condition     = contains(["Continuous7Days", "Continuous30Days"], var.backup_tier)
    error_message = "backup_tier must be Continuous7Days or Continuous30Days."
  }
}

# ---------------------------------------------------------------------------
# Databases
# ---------------------------------------------------------------------------
variable "databases" {
  type = list(object({
    name       = string
    throughput = optional(number, 400)
  }))
  description = "List of MongoDB databases to create. throughput defaults to 400 RU/s."
  default     = []
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
  description = "Set to false if privatelink.mongo.cosmos.azure.com DNS zone already exists"
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
