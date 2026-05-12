# ---------------------------------------------------------------------------
# Redis Enterprise Cluster
# ---------------------------------------------------------------------------
resource "azurerm_redis_enterprise_cluster" "this" {
  name                = local.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = var.sku_name
  minimum_tls_version = var.minimum_tls_version

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# Redis Enterprise Database
# ---------------------------------------------------------------------------
resource "azurerm_redis_enterprise_database" "this" {
  name              = "default"
  cluster_id        = azurerm_redis_enterprise_cluster.this.id
  client_protocol   = var.client_protocol
  clustering_policy = var.clustering_policy
  eviction_policy   = var.eviction_policy
  port              = var.db_port
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
  resource_id       = azurerm_redis_enterprise_cluster.this.id
  subresource_names = ["redisEnterprise"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.redisenterprise.cache.azure.net"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store access key in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "access_key" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "REDIS-PASSWORD"
  value        = azurerm_redis_enterprise_database.this.primary_access_key
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "REDIS-CONNECTION-STRING"
  value        = "rediss://:${azurerm_redis_enterprise_database.this.primary_access_key}@${azurerm_redis_enterprise_cluster.this.hostname}:${var.db_port}"
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
