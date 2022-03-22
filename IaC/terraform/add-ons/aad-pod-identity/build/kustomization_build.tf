

data "kustomization_overlay" "aad_pod_identity" {

  resources = [
    "aad-msi-binding.yaml",
  ]

  namespace = var.namespace

  patches {
    patch = <<-EOF
      - op: replace
        path: /metadata/name
        value: ${var.msi.name}
    EOF

    target = {
      kind = "AzureIdentity"
    }
  }

  patches {
    patch = <<-EOF
      - op: replace
        path: /spec/resourceID
        value: ${var.msi.id}
    EOF

    target = {
      kind = "AzureIdentity"
    }
  }

  patches {
    patch = <<-EOF
      - op: replace
        path: /spec/clientID
        value: ${var.msi.client_id}
    EOF

    target = {
      kind = "AzureIdentity"
    }
  }

  patches {
    patch = <<-EOF
      - op: replace
        path: /metadata/name
        value: ${var.msi.name}
    EOF

    target = {
      kind = "AzureIdentity"
    }
  }

  patches {
    patch = <<-EOF
      - op: replace
        path: /metadata/name
        value: ${var.msi.name}
    EOF

    target = {
      kind = "AzureIdentityBinding"
    }
  }

  patches {
    patch = <<-EOF
      - op: replace
        path: /spec/azureIdentity
        value: ${var.msi.name}
    EOF

    target = {
      kind = "AzureIdentityBinding"
    }
  }

  # You can provide a managed_identities.<key>.aadpodidentity_selector to specify the value here,
  # alternatively provide none to have the MSI name used as the selector.
  patches {
    patch = <<-EOF
      - op: replace
        path: /spec/selector
        value: ${var.msi.selector}
    EOF

    target = {
      kind = "AzureIdentityBinding"
    }
  }
}


resource "kustomization_resource" "p0" {
  for_each = data.kustomization_overlay.aad_pod_identity.ids_prio[0]
  manifest = data.kustomization_overlay.aad_pod_identity.manifests[each.value]
}

resource "kustomization_resource" "p1" {
  depends_on = [kustomization_resource.p0]
  for_each   = data.kustomization_overlay.aad_pod_identity.ids_prio[1]
  manifest   = data.kustomization_overlay.aad_pod_identity.manifests[each.value]
}

resource "kustomization_resource" "p2" {
  depends_on = [kustomization_resource.p1]
  for_each   = data.kustomization_overlay.aad_pod_identity.ids_prio[2]
  manifest   = data.kustomization_overlay.aad_pod_identity.manifests[each.value]
}
