# ---------------------------------------------------------------------------
# Service Bus Namespace
# ---------------------------------------------------------------------------
resource "azurerm_servicebus_namespace" "this" {
  name                = local.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  tags = local.all_tags
}

# ---------------------------------------------------------------------------
# Queues
# ---------------------------------------------------------------------------
# requires_session cannot be changed after creation — set it correctly the first time.
resource "azurerm_servicebus_queue" "this" {
  for_each = var.queues

  name         = each.key
  namespace_id = azurerm_servicebus_namespace.this.id

  requires_session                        = each.value.requires_session
  default_message_ttl                     = each.value.default_message_ttl
  lock_duration                           = each.value.lock_duration
  max_delivery_count                      = each.value.max_delivery_count
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
}
