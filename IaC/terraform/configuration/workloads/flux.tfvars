aks_cluster_key = "cluster_re1"

flux_settings = {
  aks_baseline = {
    namespace   = "flux-system"
    url         = "https://github.com/azure/aks-baseline-automation.git"
    branch      = "main"
    target_path = "./IaC/terraform/cluster-baseline-settings/flux"
  }
}
