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

  role_mapping_aks_clusters = {
    aks_clusters = {
      cluster_re1 = {
        "Azure Kubernetes Service RBAC Cluster Admin" = {
          object_ids = {
            keys = compact(var.clusterAdminAADGroupsObjectIds)
          }
        }
        "Azure Kubernetes Service Cluster User Role" = {
          object_ids = {
            keys = var.clusterAdminAADGroupsObjectIds == var.clusterUserAADGroupsObjectIds ? compact(var.clusterUserAADGroupsObjectIds) : compact(concat(var.clusterAdminAADGroupsObjectIds, var.clusterUserAADGroupsObjectIds))
          }
        }
        "Azure Kubernetes Service RBAC Reader" = {
          object_ids = {
            keys = compact(var.clusterUserAADGroupsObjectIds)
          }
        }
      }
    }
  }
  partial_role_mapping_merged = merge(var.role_mapping.built_in_role_mapping, local.role_mapping_aks_clusters)
  role_mapping = {
    built_in_role_mapping = local.partial_role_mapping_merged
  }

}
