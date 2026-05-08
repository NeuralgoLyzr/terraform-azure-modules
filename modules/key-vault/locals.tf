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

  # Key Vault name must be globally unique, 3–24 chars, alphanumeric + hyphens only
  key_vault_name = "${local.name_prefix}-kv"

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "key-vault"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
