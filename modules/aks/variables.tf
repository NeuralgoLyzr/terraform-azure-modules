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
# Cluster configuration
# ---------------------------------------------------------------------------
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version for the cluster (e.g. 1.31)"
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "AKS cluster SKU tier — Free (no SLA, dev/test), Standard (99.9% SLA), Premium (99.95% SLA)"
  default     = "Standard"
  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard, or Premium."
  }
}

variable "node_vm_size" {
  type        = string
  description = "VM size for the system node pool"
  default     = "Standard_D8s_v3"
}

variable "node_count" {
  type        = number
  description = "Initial number of nodes in the system node pool"
  default     = 2
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Enable cluster auto-scaler on the system node pool"
  default     = true
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes when auto-scaling is enabled"
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes when auto-scaling is enabled"
  default     = 5
}

variable "os_disk_size_gb" {
  type        = number
  description = "OS disk size in GB for each node"
  default     = 128
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "subnet_id" {
  type        = string
  description = "Subnet ID for AKS nodes (aksSubnet)"
}

variable "service_cidr" {
  type        = string
  description = "CIDR for Kubernetes services — must not overlap with VNet address space"
  default     = "10.100.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "IP address for the Kubernetes DNS service — must be within service_cidr"
  default     = "10.100.0.10"
}

# ---------------------------------------------------------------------------
# AGIC (Application Gateway Ingress Controller)
# ---------------------------------------------------------------------------
variable "app_gateway_id" {
  type        = string
  description = "Resource ID of the existing Application Gateway for AGIC add-on"
}

# ---------------------------------------------------------------------------
# Workload Identity + Key Vault CSI
# ---------------------------------------------------------------------------
variable "key_vault_secrets_provider_enabled" {
  type        = bool
  description = "Enable the Key Vault CSI secrets provider add-on"
  default     = true
}

# ---------------------------------------------------------------------------
# ACR integration (optional)
# ---------------------------------------------------------------------------
variable "acr_id" {
  type        = string
  description = "Resource ID of the Container Registry — grants AcrPull to kubelet identity (leave empty to skip)"
  default     = ""
}

# ---------------------------------------------------------------------------
# Role assignments (additional)
# ---------------------------------------------------------------------------
variable "role_assignments" {
  type = list(object({
    principal_id         = string
    role_definition_name = string
    description          = optional(string, "")
  }))
  description = "Additional RBAC role assignments on the AKS cluster"
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
