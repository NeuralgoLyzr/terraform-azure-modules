# ---------------------------------------------------------------------------
# Azure DocumentDB (MongoDB-compatible vCore cluster)
# ---------------------------------------------------------------------------
resource "azurerm_mongo_cluster" "this" {
  name                   = local.cluster_name
  resource_group_name    = var.resource_group_name
  location               = var.location

  administrator_username = var.administrator_username
  administrator_password = var.administrator_password

  shard_count            = 1
  compute_tier           = var.compute_tier
  high_availability_mode = var.high_availability_mode
  storage_size_in_gb     = var.storage_size_in_gb
  version                = var.mongo_version

  public_network_access  = var.public_network_access

  tags = local.all_tags
}

resource "azurerm_mongo_cluster_firewall_rule" "allow" {
  for_each           = toset(var.firewall_ip_rules)
  mongo_cluster_id   = azurerm_mongo_cluster.this.id
  name               = "rule-${replace(replace(each.value, "/", "-"), ".", "-")}"
  start_ip_address   = split("/", each.value)[0] == "0.0.0.0" ? "0.0.0.0" : cidrhost(each.value, 0)
  end_ip_address     = split("/", each.value)[0] == "0.0.0.0" ? "255.255.255.255" : cidrhost(each.value, -1)
}

# ---------------------------------------------------------------------------
# Private Endpoint
# ---------------------------------------------------------------------------
module "private_endpoint" {
  source = "../private-endpoint"

  company             = var.company
  product             = var.product
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  owner               = var.owner
  cost_center         = var.cost_center
  terraform_repo      = var.terraform_repo

  name              = "docdb"
  subnet_id         = var.subnet_id
  resource_id       = azurerm_mongo_cluster.this.id
  subresource_names = ["mongocluster"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.mongocluster.cosmos.azure.com"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store connection string in Key Vault
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "COSMOS-CONNECTION-STRING"
  value        = azurerm_mongo_cluster.this.connection_strings[0].value
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
