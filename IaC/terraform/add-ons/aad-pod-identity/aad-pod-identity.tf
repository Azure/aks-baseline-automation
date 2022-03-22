resource "kubernetes_namespace" "ns" {
  count = var.aad_pod_identity.namespace != {} && try(var.aad_pod_identity.create, true) ? 1 : 0

  metadata {
    name = var.aad_pod_identity.namespace
  }
}

module "build" {
  depends_on = [kubernetes_namespace.ns]
  source     = "./build"
  for_each   = local.msi
  msi        = each.value
  namespace  = var.aad_pod_identity.namespace
}



locals {
  msi = {
    for msi in [
      for msi_key, value in var.aad_pod_identity.managed_identities : {
        key       = msi_key
        selector  = try(value.selector, var.managed_identities[msi_key].name)
        client_id = var.managed_identities[msi_key].client_id
        id        = var.managed_identities[msi_key].id
        name      = var.managed_identities[msi_key].name
      }
    ]
    : msi.key => msi
  }
}
