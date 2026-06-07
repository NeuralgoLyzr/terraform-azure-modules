# ── Naming & tagging ────────────────────────────────────────────────────────
variable "company" {
  type        = string
  description = "Company short name (e.g. lyzr)"
}

variable "product" {
  type        = string
  description = "Product name (e.g. studio)"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, prod)"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to deploy into"
}

variable "owner" {
  type        = string
  description = "Team or person responsible"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing"
}

variable "terraform_repo" {
  type        = string
  description = "Terraform repo name for traceability"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged with mandatory tags"
  default     = {}
}

# ── VM identity ──────────────────────────────────────────────────────────────
variable "vm_name_suffix" {
  type        = string
  description = "Suffix appended to name prefix (e.g. clickhouse-vm, qdrant-vm)"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size (e.g. Standard_D4s_v3)"
}

variable "admin_username" {
  type        = string
  description = "OS admin username"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "OS admin password"
}

# ── Networking ───────────────────────────────────────────────────────────────
variable "subnet_id" {
  type        = string
  description = "Subnet resource ID to attach the NIC to"
}

variable "private_ip_address" {
  type        = string
  description = "Static private IP address within the subnet"
}

variable "nsg_inbound_rules" {
  type = list(object({
    name                   = string
    priority               = number
    destination_port_range = string
    source_address_prefix  = string
  }))
  description = "Inbound NSG rules. SSH from VNet is always added automatically."
  default     = []
}

# ── Disks ────────────────────────────────────────────────────────────────────
variable "os_disk_storage_account_type" {
  type        = string
  description = "OS disk storage type"
  default     = "Premium_LRS"
}

variable "data_disk_size_gb" {
  type        = number
  description = "Data disk size in GB. Set to 0 to skip data disk creation."
  default     = 0
}

variable "data_disk_storage_account_type" {
  type        = string
  description = "Data disk storage type"
  default     = "Premium_LRS"
}

# ── Managed identity ─────────────────────────────────────────────────────────
variable "managed_identity_id" {
  type        = string
  description = "User-assigned managed identity resource ID"
}

# ── Custom script ────────────────────────────────────────────────────────────
variable "custom_script_command" {
  type        = string
  description = "Shell command run via CustomScript extension after VM boot. Leave empty to skip."
  default     = ""
}
