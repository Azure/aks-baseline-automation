provider "azurerm" {
  partner_id = "451dc593-a3a3-4d41-91e7-3aadf93e1a78"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurerm" {
  alias                      = "vhub"
  skip_provider_registration = true
  features {}
  subscription_id = data.azurerm_client_config.default.subscription_id
  tenant_id       = data.azurerm_client_config.default.tenant_id
}

data "azurerm_client_config" "default" {}

provider "kubectl" {
  host                   = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.host, null)
  username               = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.username, null)
  password               = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.password, null)
  client_key             = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.client_key), null)
  client_certificate     = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.client_certificate), null)
  cluster_ca_certificate = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.cluster_ca_certificate), null)
  load_config_file       = false
}

provider "kubernetes" {
  host                   = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.host, null)
  username               = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.username, null)
  password               = try(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.password, null)
  client_key             = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.client_key), null)
  client_certificate     = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.client_certificate), null)
  cluster_ca_certificate = try(base64decode(module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config.0.cluster_ca_certificate), null)
}

provider "kustomization" {
  kubeconfig_raw = module.caf.aks_clusters[var.aks_cluster_key].kubeconfig.kube_admin_config_raw
}
