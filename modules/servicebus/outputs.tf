output "namespace_id" {
  value       = azurerm_servicebus_namespace.this.id
  description = "Service Bus Namespace resource ID"
}

output "namespace_name" {
  value       = azurerm_servicebus_namespace.this.name
  description = "Service Bus Namespace name"
}

output "namespace_connection_string" {
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  description = "Primary connection string for the Service Bus Namespace"
  sensitive   = true
}

output "queue_ids" {
  value       = { for k, q in azurerm_servicebus_queue.this : k => q.id }
  description = "Map of queue name to resource ID"
}
