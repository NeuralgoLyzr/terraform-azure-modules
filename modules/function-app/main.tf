# ---------------------------------------------------------------------------
# Storage Account — required by Azure Functions runtime
# ---------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# App Service Plan — Elastic Premium for production scale-out
# ---------------------------------------------------------------------------
resource "azurerm_service_plan" "this" {
  name                = local.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# Function Apps
# ---------------------------------------------------------------------------
resource "azurerm_linux_function_app" "this" {
  for_each = var.function_apps

  name                       = "${local.prefix}-${each.key}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  service_plan_id            = azurerm_service_plan.this.id
  storage_account_name       = azurerm_storage_account.this.name
  storage_account_access_key = azurerm_storage_account.this.primary_access_key
  https_only                 = true

  app_settings = merge(
    {
      FUNCTIONS_EXTENSION_VERSION  = "~4"
      WEBSITE_RUN_FROM_PACKAGE     = each.value.deployment_type == "zip" ? "1" : null
      ServiceBusConnection         = var.servicebus_connection_string
    },
    each.value.app_settings
  )

  site_config {
    # zip-deployed: python
    dynamic "application_stack" {
      for_each = each.value.deployment_type == "zip" && each.value.runtime == "python" ? [1] : []
      content {
        python_version = each.value.runtime_version
      }
    }

    # zip-deployed: node
    dynamic "application_stack" {
      for_each = each.value.deployment_type == "zip" && each.value.runtime == "node" ? [1] : []
      content {
        node_version = "~${each.value.runtime_version}"
      }
    }

    # container-deployed
    dynamic "application_stack" {
      for_each = each.value.deployment_type == "container" ? [1] : []
      content {
        docker {
          registry_url      = each.value.container_registry_url
          image_name        = each.value.container_image_name
          image_tag         = each.value.container_image_tag
          registry_username = each.value.container_registry_username != "" ? each.value.container_registry_username : null
          registry_password = each.value.container_registry_password != "" ? each.value.container_registry_password : null
        }
      }
    }
  }

  tags = local.all_tags
}
