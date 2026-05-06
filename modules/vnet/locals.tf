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

  vnet_name  = "${local.name_prefix}-vnet"
  natgw_name = "${local.name_prefix}-natgw"
  natgw_pip  = "${local.name_prefix}-natgw-pip"

  # Subnets that need NSGs — gatewaySubnet cannot have an NSG in Azure
  subnets_with_nsg = {
    for k, v in var.subnets : k => v if k != "gatewaySubnet"
  }

  mandatory_tags = {
    Environment   = var.environment
    Product       = var.product
    ManagedBy     = "terraform"
    Owner         = var.owner
    CostCenter    = var.cost_center
    TerraformRepo = var.terraform_repo
    Module        = "vnet"
  }

  all_tags = merge(local.mandatory_tags, var.tags)
}
