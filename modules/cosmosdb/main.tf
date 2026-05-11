# ---------------------------------------------------------------------------
# CosmosDB Account (MongoDB API)
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_account" "this" {
  name                = local.account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "MongoDB"
  mongo_server_version = var.mongo_server_version

  public_network_access_enabled = false

  consistency_policy {
    consistency_level = var.consistency_level
  }

  # Primary write region
  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # Optional read replica
  dynamic "geo_location" {
    for_each = var.secondary_location != "" ? [1] : []
    content {
      location          = var.secondary_location
      failover_priority = 1
    }
  }

  backup {
    type = "Continuous"
    tier = var.backup_tier
  }

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# MongoDB Databases
# ---------------------------------------------------------------------------
resource "azurerm_cosmosdb_mongo_database" "this" {
  for_each            = { for db in var.databases : db.name => db }
  name                = each.key
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = each.value.throughput
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

  name              = "cosmos"
  subnet_id         = var.subnet_id
  resource_id       = azurerm_cosmosdb_account.this.id
  subresource_names = ["MongoDB"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.mongo.cosmos.azure.com"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store connection string in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "COSMOS-CONNECTION-STRING"
  value        = azurerm_cosmosdb_account.this.connection_strings[0]
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
