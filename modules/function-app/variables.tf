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
# Naming overrides
# ---------------------------------------------------------------------------
variable "storage_account_name" {
  type        = string
  description = "Override auto-generated storage account name (max 24 chars, no hyphens)"
  default     = ""
}

variable "service_plan_name" {
  type        = string
  description = "Override auto-generated service plan name"
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
# Service Plan
# ---------------------------------------------------------------------------
variable "service_plan_sku" {
  type        = string
  description = "App Service Plan SKU. Use EP1/EP2/EP3 (Elastic Premium) for production."
  default     = "EP1"
  validation {
    condition     = contains(["EP1", "EP2", "EP3", "Y1"], var.service_plan_sku)
    error_message = "service_plan_sku must be EP1, EP2, EP3 (Elastic Premium) or Y1 (Consumption)."
  }
}

# ---------------------------------------------------------------------------
# Shared Service Bus connection string
# ---------------------------------------------------------------------------
variable "servicebus_connection_string" {
  type        = string
  description = "Azure Service Bus namespace connection string — injected as ServiceBusConnection app setting"
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Function Apps
# ---------------------------------------------------------------------------
variable "function_apps" {
  description = "Map of Function Apps to create. Key is appended to the resource name prefix."
  type = map(object({
    # Runtime — required for zip-deployed functions
    runtime         = optional(string, "")  # python, node, dotnet
    runtime_version = optional(string, "")  # 3.11, 20, 8.0

    # Container — required when deployment_type = "container"
    deployment_type        = optional(string, "zip")  # zip | container
    container_registry_url = optional(string, "")
    container_image_name   = optional(string, "")
    container_image_tag    = optional(string, "latest")
    container_registry_username = optional(string, "")
    container_registry_password = optional(string, "")

    # Extra app settings merged with shared defaults
    app_settings = optional(map(string), {})
  }))
}
