# locals variables created as a helper to pass variables from the GitHub workflow
locals {
  resource_groups = { for k, v in var.resource_groups : k =>
    {
      name   = length(var.regions) == 0 ? "${v.name}-${var.global_settings.regions[v.region]}" : "${v.name}-${var.regions[0]}"
      region = v.region
    }
  }

  global_settings = length(var.regions) == 0 ? var.global_settings : {
    default_region = "region1"
    regions        = { for region in var.regions : "region${index(var.regions, region) + 1}" => region }
    passthrough    = true
  }

}
