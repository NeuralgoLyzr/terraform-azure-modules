locals {
  region_short = {
    "westeurope"    = "we"
    "eastus"        = "eus"
    "eastus2"       = "eus2"
    "northeurope"   = "ne"
    "westus"        = "wus"
    "westus2"       = "wus2"
    "centralus"     = "cus"
    "southeastasia" = "sea"
    "uksouth"       = "uks"
    "ukwest"        = "ukw"
  }

  region_code = local.region_short[var.location]
  prefix      = "${var.company}-${var.product}-${var.environment}-${local.region_code}"

  # Storage account: no hyphens, max 24 chars
  storage_account_name = var.storage_account_name != "" ? var.storage_account_name : "${var.company}${var.product}${var.environment}${local.region_code}fnsa"

  service_plan_name = var.service_plan_name != "" ? var.service_plan_name : "${local.prefix}-func-plan"

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "function-app"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
