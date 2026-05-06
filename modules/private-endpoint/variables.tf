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
# Private Endpoint config
# ---------------------------------------------------------------------------
variable "name" {
  type        = string
  description = "Short name for this private endpoint (e.g. postgres, cosmosdb, redis)"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID where the private endpoint NIC will be placed"
}

variable "resource_id" {
  type        = string
  description = "Resource ID of the Azure service to connect (e.g. PostgreSQL server ID)"
}

variable "subresource_names" {
  type        = list(string)
  description = "Subresource names for the private endpoint (e.g. [\"postgresqlServer\"], [\"mongoDb\"])"
}

# ---------------------------------------------------------------------------
# Private DNS Zone
# ---------------------------------------------------------------------------
variable "create_dns_zone" {
  type        = bool
  description = "Set to false if the private DNS zone already exists"
  default     = true
}

variable "existing_dns_zone_id" {
  type        = string
  description = "Resource ID of an existing private DNS zone (only used when create_dns_zone = false)"
  default     = ""
}

variable "private_dns_zone_name" {
  type        = string
  description = "Private DNS zone name (e.g. privatelink.postgres.database.azure.com)"
}

variable "vnet_id" {
  type        = string
  description = "VNet ID to link the private DNS zone to"
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
