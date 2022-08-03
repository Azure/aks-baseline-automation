application_gateway_applications = {
  aspnetapp_az1_agw1 = {

    name                    = "aspnetapp"
    application_gateway_key = "agw1_az1"

    listeners = {
      public_ssl = {
        name                           = "public-443"
        front_end_ip_configuration_key = "public"
        front_end_port_key             = "443"
        # host_name                      = "www.y4plq60ubbbiop9w1dh36tlgfpxqctfj.com"
        dns_zone = {
          key         = "dns_zone1"
          record_type = "a"
          record_key  = "agw"
        }

        request_routing_rule_key = "default"
        # key_vault_secret_id = ""
        # keyvault_certificate = {
        #   certificate_key = "aspnetapp.cafdemo.com"
        # }
        keyvault_certificate_request = {
          key = "appgateway"
        }
      }
    }


    request_routing_rules = {
      default = {
        rule_type = "Basic"
      }
    }

    backend_http_setting = {
      port                                = 80
      protocol                            = "Http"
      pick_host_name_from_backend_address = true
      timeout                             = 20
      cookie_based_affinity               = "Disabled"
      probe_key                           = "probe_1"
    }

    probes = {
      probe_1 = {
        name                                      = "probe-fqdn-backend-aks"
        protocol                                  = "Http"
        path                                      = "/favicon.ico"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        min_servers                               = 0
        pick_host_name_from_backend_http_settings = true
      }
    }

    backend_pool = {
      fqdns = [
        "bu0001a0008-00.aks-ingress.contoso.com"
      ]
    }

  }
}
