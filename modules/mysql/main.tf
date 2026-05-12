data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Generated temp admin password
# ---------------------------------------------------------------------------
resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ---------------------------------------------------------------------------
# MySQL Flexible Server
# ---------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server" "this" {
  name                = local.server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.mysql_version

  administrator_login    = var.admin_username
  administrator_password = random_password.admin.result

  sku_name = var.sku_name

  storage {
    size_gb           = var.storage_size_gb
    iops              = var.iops
    auto_grow_enabled = var.auto_grow_enabled
  }

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  dynamic "high_availability" {
    for_each = var.high_availability_mode != "Disabled" ? [1] : []
    content {
      mode = var.high_availability_mode
    }
  }

  tags = local.all_tags

  lifecycle {
    ignore_changes = [zone, administrator_password]
  }
}

# ---------------------------------------------------------------------------
# Entra ID (AAD) administrator — managed identity
# ---------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server_active_directory_administrator" "this" {
  server_id   = azurerm_mysql_flexible_server.this.id
  identity_id = var.managed_identity_id
  login       = var.managed_identity_name
  object_id   = var.managed_identity_principal_id
  tenant_id   = data.azurerm_client_config.current.tenant_id
}

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------
resource "azurerm_mysql_flexible_server_database" "this" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.this.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"

  depends_on = [azurerm_mysql_flexible_server_active_directory_administrator.this]
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

  name              = "mysql"
  subnet_id         = var.subnet_id
  resource_id       = azurerm_mysql_flexible_server.this.id
  subresource_names = ["mysqlServer"]

  create_dns_zone       = var.create_private_dns_zone
  existing_dns_zone_id  = var.existing_private_dns_zone_id
  private_dns_zone_name = "privatelink.mysql.database.azure.com"
  vnet_id               = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Store secrets in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "mysql_password" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "MYSQL-ADMIN-PASSWORD"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "mysql_host" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "MYSQL-HOST"
  value        = azurerm_mysql_flexible_server.this.fqdn
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
