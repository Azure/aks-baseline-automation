diagnostics_definition = {
  azure_container_registry = {
    name = "operational_logs_and_metrics"
    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["ContainerRegistryRepositoryEvents", true, false, 7],
        ["ContainerRegistryLoginEvents", true, false, 7],
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["AllMetrics", true, false, 7],
      ]
    }
  }
  azure_kubernetes_cluster = {
    name = "aks_logs_and_metrics"
    categories = {
      log = [
        # ["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["kube-apiserver", true, false, 7],
        ["kube-audit", false, false, 0],
        ["kube-audit-admin", true, false, 7],
        ["kube-controller-manager", true, false, 7],
        ["kube-scheduler", false, false, 0],
        ["cluster-autoscaler", true, false, 7],
        ["guard", true, false, 7],
        ["cloud-controller-manager", false, false, 0],
        ["csi-azuredisk-controller", false, false, 0],
        ["csi-azurefile-controller", false, false, 0],
        ["csi-snapshot-controller", false, false, 0]
      ]
      metric = [
        #["Category name",  "Diagnostics Enabled(true/false)", "Retention Enabled(true/false)", Retention_period]
        ["AllMetrics", true, false, 7],
      ]
    }
  }
}