
keyvaults = {

  # This keyvault is used to store the complex password created for the AKS breakglass admin user
  secrets = {
    name                      = "secretsvault_re1"
    resource_group_key        = "aks_re1"
    region                    = "region1"
    sku_name                  = "premium"
    enable_rbac_authorization = true

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
  }
}
