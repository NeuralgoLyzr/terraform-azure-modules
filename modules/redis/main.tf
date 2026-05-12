# ---------------------------------------------------------------------------
# Resource group data source (needed for parent_id)
# ---------------------------------------------------------------------------
data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

# ---------------------------------------------------------------------------
# Azure Managed Redis Cluster (via AzAPI — supports Balanced_B* SKUs)
# ---------------------------------------------------------------------------
resource "azapi_resource" "redis_cluster" {
  type      = "Microsoft.Cache/redisEnterprise@2025-07-01"
  name      = local.cluster_name
  location  = var.location
  parent_id = data.azurerm_resource_group.this.id

  body = {
    sku = {
      name = var.sku_name
    }
    properties = {
      minimumTlsVersion   = var.minimum_tls_version
      publicNetworkAccess = "Disabled"
    }
  }

  tags = local.all_tags

  schema_validation_enabled = false
  response_export_values    = ["properties.hostName"]
}

# ---------------------------------------------------------------------------
# Redis Enterprise Database
# ---------------------------------------------------------------------------
resource "azapi_resource" "redis_database" {
  type      = "Microsoft.Cache/redisEnterprise/databases@2025-07-01"
  name      = "default"
  parent_id = azapi_resource.redis_cluster.id

  body = {
    properties = {
      clientProtocol           = var.client_protocol
      clusteringPolicy         = var.clustering_policy
      evictionPolicy           = var.eviction_policy
      port                     = var.db_port
      accessKeysAuthentication = "Enabled"
      persistence = {
        aofEnabled = var.aof_enabled
        rdbEnabled = var.rdb_enabled
      }
    }
  }

  schema_validation_enabled = false
}

# ---------------------------------------------------------------------------
# Retrieve access keys
# ---------------------------------------------------------------------------
data "azapi_resource_action" "redis_keys" {
  type        = "Microsoft.Cache/redisEnterprise/databases@2025-07-01"
  resource_id = azapi_resource.redis_database.id
  action      = "listKeys"
  method      = "POST"

  response_export_values = ["*"]
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

  name              = "redis"
  subnet_id         = var.subnet_id
  resource_id       = azapi_resource.redis_cluster.id
  subresource_names = ["redisEnterprise"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.redisenterprise.cache.azure.net"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store secrets in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "access_key" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "REDIS-PASSWORD"
  value        = data.azapi_resource_action.redis_keys.output.primaryKey
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "REDIS-CONNECTION-STRING"
  value        = "rediss://:${data.azapi_resource_action.redis_keys.output.primaryKey}@${azapi_resource.redis_cluster.output.properties.hostName}:${var.db_port}"
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
