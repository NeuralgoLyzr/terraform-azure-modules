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
# Redis Enterprise cluster configuration
# ---------------------------------------------------------------------------
variable "sku_name" {
  type        = string
  description = "Redis Enterprise SKU (e.g. Balanced_B3, Balanced_B5, Balanced_B10)"
  default     = "Balanced_B3"
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the cluster"
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

# ---------------------------------------------------------------------------
# Redis Enterprise database configuration
# ---------------------------------------------------------------------------
variable "db_port" {
  type        = number
  description = "Port for the Redis Enterprise database"
  default     = 10000
}

variable "eviction_policy" {
  type        = string
  description = "Eviction policy for the database"
  default     = "NoEviction"
  validation {
    condition     = contains(["NoEviction", "AllKeysLRU", "AllKeysLFU", "AllKeysRandom", "VolatileLRU", "VolatileLFU", "VolatileRandom", "VolatileTTL"], var.eviction_policy)
    error_message = "Invalid eviction_policy."
  }
}

variable "client_protocol" {
  type        = string
  description = "Redis client protocol: Encrypted or Plaintext"
  default     = "Encrypted"
  validation {
    condition     = contains(["Encrypted", "Plaintext"], var.client_protocol)
    error_message = "client_protocol must be Encrypted or Plaintext."
  }
}

variable "clustering_policy" {
  type        = string
  description = "Clustering policy: EnterpriseCluster or OSSCluster"
  default     = "EnterpriseCluster"
  validation {
    condition     = contains(["EnterpriseCluster", "OSSCluster"], var.clustering_policy)
    error_message = "clustering_policy must be EnterpriseCluster or OSSCluster."
  }
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
  description = "Set to false if privatelink.redisenterprise.cache.azure.net DNS zone already exists"
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
  description = "Key Vault ID to store the primary access key (leave empty to skip)"
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
