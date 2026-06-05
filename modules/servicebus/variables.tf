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

variable "namespace_name" {
  type        = string
  description = "Override the auto-generated namespace name. Defaults to <company>-<product>-<env>-<region>-sbus"
  default     = ""
}

# ---------------------------------------------------------------------------
# Tagging inputs
# ---------------------------------------------------------------------------
variable "owner" {
  type        = string
  description = "Team or person responsible for these resources"
  default     = "devops-team"
}

variable "cost_center" {
  type        = string
  description = "Cost center for billing allocation"
  default     = "engineering"
}

variable "terraform_repo" {
  type        = string
  description = "Terraform repository managing these resources"
  default     = "lyzr-studio-infra-azure"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to merge with mandatory tags"
  default     = {}
}

# ---------------------------------------------------------------------------
# Service Bus configuration
# ---------------------------------------------------------------------------
variable "sku" {
  type        = string
  description = "Service Bus SKU — Basic, Standard, or Premium"
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "queues" {
  description = "Map of Service Bus queues to create. Key is the queue name."
  type = map(object({
    requires_session                        = optional(bool, false)
    default_message_ttl                     = optional(string, "P14D")
    lock_duration                           = optional(string, "PT1M")
    max_delivery_count                      = optional(number, 10)
    dead_lettering_on_message_expiration    = optional(bool, true)
    requires_duplicate_detection            = optional(bool, false)
    duplicate_detection_history_time_window = optional(string, "PT10M")
  }))
  default = {}
}
