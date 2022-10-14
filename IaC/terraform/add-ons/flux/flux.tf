module "flux_addon" {
  source   = "github.com/Azure/caf-terraform-landingzones/caf_solution/add-ons/aks_secure_baseline_v2/flux"
  # source   = "../../landingzone/caf_solution/add-ons/aks_secure_baseline_v2/flux"
  for_each = var.flux_settings
  setting  = each.value
}

output "flux_output" {
  value = module.flux_addon
}
