aad_pod_identity = {
  create    = false
  namespace = "a0008"
  managed_identities = {
    ingress = { # this is the key of the managed identity
      selector = "podmi-ingress-controller"
    }
  }
}
