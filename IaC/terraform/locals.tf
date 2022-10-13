locals {
  global_settings = length(var.regions) == 0 ? var.global_settings : {
    default_region = "region1"
    regions        = { for region in var.regions : "region${index(var.regions, region) + 1}" => region }
    passthrough    = true
  }
}
