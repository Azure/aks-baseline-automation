variable "aks_cluster_key" {
  description = "AKS cluster key to deploy AAD Pod identities CRDs objects. The key must be defined in the variable aks_clusters"
}
variable "caf_config" {
  default = {}
}
variable "vnets" {
  default = {}
}
variable "managed_identities" {
  description = "Map of the user managed identities."
}

variable "aad_pod_identity" {}
