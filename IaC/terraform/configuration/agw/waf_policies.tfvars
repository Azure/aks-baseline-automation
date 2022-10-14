application_gateway_waf_policies = {
  wp1 = {
    name               = "waf-akscluster-re1-001"
    resource_group_key = "aks_re1"

    policy_settings = {
      enabled                 = true
      mode                    = "Prevention"
      file_upload_limit_in_mb = 10
    }

    managed_rules = {
      managed_rule_set = {
        mrs1 = {
          type    = "OWASP"
          version = "3.2"
        }
        mrs2 = {
          type    = "Microsoft_BotManagerRuleSet"
          version = "0.1"
        }
      }
    }
  }
}
