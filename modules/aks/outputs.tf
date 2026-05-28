output "cluster_id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "AKS cluster resource ID"
}

output "cluster_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "AKS cluster name"
}

output "kube_config" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  description = "Raw kubeconfig for kubectl access"
  sensitive   = true
}

output "oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
  description = "OIDC issuer URL — used to create federated identity credentials for workload identity"
}

output "kubelet_identity_object_id" {
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  description = "Object ID of the kubelet managed identity — used for ACR pull and other node-level permissions"
}

output "kubelet_identity_client_id" {
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].client_id
  description = "Client ID of the kubelet managed identity"
}

output "cluster_identity_principal_id" {
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
  description = "Principal ID of the cluster system-assigned identity — used for AGIC and network permissions"
}

output "host" {
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  description = "AKS API server hostname"
  sensitive   = true
}
