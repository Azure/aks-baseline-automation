application_gateway_applications_v1 = {
  aspnetapp_az1_agw1 = {

    name                    = "aspnetapp"
    application_gateway_key = "agw1_az1"

    http_listeners = {
      public_ssl = {
        name                           = "public-443"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "443"
        ssl_cert_key                   = "sslagwcert"
      }
    }

    request_routing_rules = {
      default = {
        name              = "default_request_routing_rule_1"
        rule_type         = "Basic"
        http_listener_key = "public_ssl"
        backend_pool_key  = "backend_pool_1"
        http_settings_key = "http_setting_1"
        priority          = 100
      }
    }

    http_settings = {
      http_setting_1 = {
        name                        = "aks_http_setting_1"
        front_end_port_key          = "443"
        root_certs                  = "wildcard-ingress"
        host_name_from_backend_pool = true
        timeout                     = 20
        cookie_based_affinity       = "Disabled"
        enable_probe                = true
        probe_key                   = "probe_1"
      }
    }

    probes = {
      probe_1 = {
        name                         = "probe-fqdn-backend-aks"
        protocol                     = "Https"
        path                         = "/"
        interval                     = 30
        timeout                      = 30
        threshold                    = 3
        min_servers                  = 0
        host_name_from_http_settings = true
      }
    }

    backend_pools = {
      backend_pool_1 = {
        name = "aks-pool-1"
        fqdns = [
          "bu0001a0008-00.aks-ingress.contoso.com"
        ]
      }
    }

  }
}
