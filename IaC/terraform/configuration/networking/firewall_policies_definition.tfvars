azurerm_firewall_policies = {
  base_policy = {
    name               = "fw-policies-base"
    resource_group_key = "vnet_hub_re1"
    sku                = "Premium"

    threat_intelligence_mode = "Deny"

    dns = {
      proxy_enabled = true
    }

    intrusion_detection = {
      mode = "Deny"
    }
  }
  policies = {
    name               = "fw-policies"
    resource_group_key = "vnet_hub_re1"
    sku                = "Premium"

    threat_intelligence_mode = "Deny"

    dns = {
      proxy_enabled = true
    }

    intrusion_detection = {
      mode = "Deny"
    }
  }
}
