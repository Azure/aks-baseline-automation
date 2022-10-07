module "flux_addon" {
  depends_on = [
    module.caf.role_mapping
  ]
  source        = "./add-ons/flux"
  flux_settings = var.flux_settings
}

output "flux_addon_output" {
  value = module.flux_addon
}
