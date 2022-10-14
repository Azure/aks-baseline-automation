module "flux_addon" {
  source          = "./add-ons/flux"
  flux_settings   = var.flux_settings
  caf_config      = module.caf
  aks_cluster_key = var.aks_cluster_key
}

output "flux_addon_output" {
  value = module.flux_addon.flux_output
}
