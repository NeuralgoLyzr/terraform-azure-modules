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
  name_prefix = "${var.company}-${var.product}-${var.environment}-${local.region_code}"

  # ACR name must be globally unique, 5–50 chars, alphanumeric only (no hyphens)
  registry_name = replace("${local.name_prefix}-acr", "-", "")

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "container-registry"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
