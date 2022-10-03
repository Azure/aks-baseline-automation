module "flux_addon" {
  source        = "./add-ons/flux"
  flux_settings = var.flux_settings
}

output "flux_addon_output" {
  value = module.flux_addon
}
