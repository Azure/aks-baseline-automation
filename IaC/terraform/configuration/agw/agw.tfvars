application_gateways = {
  agw1_az1 = {
    resource_group_key = "aks_re1"
    name               = "appgateway-re1-001"
    vnet_key           = "vnet_aks_re1"
    subnet_key         = "application_gateway"
    sku_name           = "WAF_v2"
    sku_tier           = "WAF_v2"
    capacity = {
      autoscale = {
        minimum_scale_unit = 0
        maximum_scale_unit = 10
      }
    }
    zones        = ["1"]
    enable_http2 = false

    ssl_profiles = {
      profile1 = {
        name = "SecureTLS"
        ssl_policy = {
          min_protocol_version = "TLSv1_2"
        }
      }
    }

    identity = {
      managed_identity_keys = [
        "apgw_keyvault_secrets"
      ]
    }

    front_end_ip_configurations = {
      public = {
        name          = "public"
        public_ip_key = "agw_pip1_re1"
        subnet_key    = "application_gateway"
      }
    }

    front_end_ports = {
      80 = {
        name     = "http-80"
        port     = 80
        protocol = "Http"
      }
      443 = {
        name     = "https-443"
        port     = 443
        protocol = "Https"
      }
    }

    trusted_root_certificate = {
      wildcard_ingress = {
        name = "wildcard-ingress"
        # data =
        keyvault_key = "secrets"
      }
    }

    diagnostic_profiles = {
      operations = {
        name             = "agw_logs"
        definition_key   = "azure_application_gateway"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
  }
}
