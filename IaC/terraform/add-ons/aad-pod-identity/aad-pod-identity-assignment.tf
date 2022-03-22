resource "azurerm_role_assignment" "kubelet_user_msi" {
  for_each = local.msi_to_grant_permissions

  scope                = each.value.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.aks_clusters[var.aks_cluster_key].kubelet_identity[0].object_id
}

locals {
  msi_to_grant_permissions = {
    for msi in [
      for msi_key, value in var.aad_pod_identity.managed_identities : {
        key          = msi_key
        id           = var.managed_identities[msi_key].id
        principal_id = var.managed_identities[msi_key].principal_id
      }
    ]
    : msi.key => msi
  }
}
