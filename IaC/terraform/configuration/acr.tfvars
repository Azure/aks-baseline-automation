azure_container_registries = {
  acr1 = {
    name               = "acr-re1-001"
    resource_group_key = "aks_re1"
    sku                = "Premium"
    diagnostic_profiles = {
      operations = {
        name             = "acr_logs"
        definition_key   = "azure_container_registry"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
    # georeplication_region_keys = ["region2"]

    network_rule_set = {
      deny_public_access = {
        default_action = "Deny"
      }
    }

    private_endpoints = {
      # Require enforce_private_link_endpoint_network_policies set to true on the subnet
      spoke_aks_re1-aks_nodepool_system = {
        name               = "acr-re1-001-private-link"
        resource_group_key = "aks_re1"

        vnet_key   = "vnet_aks_re1"
        subnet_key = "private_endpoints"

        private_service_connection = {
          name                 = "acr-re1-001-private-link-psc"
          is_manual_connection = false
          subresource_names    = ["registry"]
        }
      }
    }

  }
}
