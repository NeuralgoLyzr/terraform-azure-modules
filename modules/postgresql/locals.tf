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

  server_name  = "${local.name_prefix}-psql"
  dns_link_name = "${local.name_prefix}-psql-dns-link"

  private_dns_zone_id = var.create_private_dns_zone ? azurerm_private_dns_zone.this[0].id : var.existing_private_dns_zone_id

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "postgresql"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
