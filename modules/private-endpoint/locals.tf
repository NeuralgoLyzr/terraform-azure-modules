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

  pe_name       = "${local.name_prefix}-${var.name}-pe"
  dns_zone_link = "${local.name_prefix}-${var.name}-dns-link"

  dns_zone_id = var.create_dns_zone ? azurerm_private_dns_zone.this[0].id : var.existing_dns_zone_id

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "private-endpoint"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
