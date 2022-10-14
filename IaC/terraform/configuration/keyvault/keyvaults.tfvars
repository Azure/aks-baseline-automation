
keyvaults = {

  # This keyvault is used to store the complex password created for the AKS breakglass admin user
  secrets = {
    name                            = "secretsvaultre001"
    resource_group_key              = "aks_re1"
    region                          = "region1"
    sku_name                        = "premium"
    enabled_for_template_deployment = true
    enable_rbac_authorization       = false # Not supported yet by CAF Modules 5.6.1

    creation_policies = {
      logged_in_user = {
        # if the key is set to "logged_in_user" add the user running terraform in the keyvault policy
        secret_permissions      = ["Set", "Get", "List", "Delete", "Purge", "Recover"]
        certificate_permissions = ["Create", "Get", "List", "Delete", "Purge", "Recover"]
      }
      ingress_umi = {
        managed_identity_key    = "ingress"
        secret_permissions      = ["Get"]
        certificate_permissions = ["Get"]
      }
      apgw_keyvault_secrets_umi = {
        managed_identity_key    = "apgw_keyvault_secrets"
        certificate_permissions = ["Get"]
        secret_permissions      = ["Get"]
      }
    }

    network = {
      bypass         = "AzureServices"
      default_action = "Allow" # Set the default_action to "Deny" when CICD self-hosted runner is connected to any subnet
      subnets = {
        subnethub = {
          vnet_key   = "vnet_hub_re1"
          subnet_key = "AzureBastionSubnet"
        }
        subnetspoke = {
          vnet_key   = "vnet_aks_re1"
          subnet_key = "aks_nodepool_system"
        }
      }
    }

    diagnostic_profiles = {
      operations = {
        name             = "akv_logs"
        definition_key   = "azure_key_vault"
        destination_type = "log_analytics"
        destination_key  = "central_logs"
      }
    }
  }
}
