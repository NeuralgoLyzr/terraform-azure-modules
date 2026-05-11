# ---------------------------------------------------------------------------
# Generated admin password
# ---------------------------------------------------------------------------
resource "random_password" "admin" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# ---------------------------------------------------------------------------
# Private DNS zone for PostgreSQL VNet integration
# ---------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "this" {
  count               = var.create_private_dns_zone ? 1 : 0
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = local.all_tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = local.dns_link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.create_private_dns_zone ? azurerm_private_dns_zone.this[0].name : split("/", var.existing_private_dns_zone_id)[8]
  virtual_network_id    = var.vnet_id
  tags                  = local.all_tags
}

# ---------------------------------------------------------------------------
# PostgreSQL Flexible Server
# ---------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = local.server_name
  resource_group_name    = var.resource_group_name
  location               = var.location

  version                = var.postgres_version
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = local.private_dns_zone_id

  administrator_login    = var.admin_username
  administrator_password = random_password.admin.result

  sku_name               = var.sku_name
  storage_mb             = var.storage_mb
  zone                   = var.availability_zone != "" ? var.availability_zone : null

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup
  public_network_access_enabled = false

  dynamic "high_availability" {
    for_each = var.enable_high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_availability_zone
    }
  }

  tags = local.all_tags

  lifecycle {
    ignore_changes = [zone]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.this]
}

# ---------------------------------------------------------------------------
# Server configurations
# ---------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_configuration" "ssl" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_connections" {
  name      = "log_connections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_disconnections" {
  name      = "log_disconnections"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"
}

resource "azurerm_postgresql_flexible_server_configuration" "log_statement" {
  name      = "log_statement"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "ddl"
}

# ---------------------------------------------------------------------------
# Databases
# ---------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server_database" "this" {
  for_each  = toset(var.databases)
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# ---------------------------------------------------------------------------
# Store admin password in Key Vault (optional)
# ---------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "postgres_password" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "POSTGRES-PASSWORD"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  count        = var.key_vault_id != "" ? 1 : 0
  name         = "POSTGRES-CONNECTION-STRING"
  value        = "postgresql://${var.admin_username}:${random_password.admin.result}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${var.databases[0]}?sslmode=require"
  key_vault_id = var.key_vault_id

  tags = local.all_tags
}
