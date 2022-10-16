vnets = {
  vnet_hub_re1 = {
    resource_group_key = "vnet_hub_re1"
    region             = "region1"
    vnet = {
      name          = "vnet_hub_re1"
      address_space = ["10.200.0.0/24"]
    }
    specialsubnets = {
      GatewaySubnet = {
        name = "GatewaySubnet" #Must be called GateWaySubnet in order to host a Virtual Network Gateway
        cidr = ["10.200.0.64/27"]
      }
      AzureFirewallSubnet = {
        name = "AzureFirewallSubnet" #Must be called AzureFirewallSubnet
        cidr = ["10.200.0.0/26"]
      }
    }
    subnets = {
      AzureBastionSubnet = {
        name              = "AzureBastionSubnet" #Must be called AzureBastionSubnet
        cidr              = ["10.200.0.96/27"]
        nsg_key           = "azure_bastion_nsg"
        service_endpoints = ["Microsoft.KeyVault"]
      }
    }
  }
  vnet_aks_re1 = {
    resource_group_key = "aks_spoke_re1"
    region             = "region1"
    vnet = {
      name          = "aks"
      address_space = ["10.240.0.0/16"]
    }
    subnets = {
      aks_nodepool_system = {
        name              = "snet-clusternodes"
        cidr              = ["10.240.0.0/22"]
        nsg_key           = "azure_kubernetes_cluster_nsg"
        route_table_key   = "default_to_firewall_re1"
        service_endpoints = ["Microsoft.KeyVault"]
      }
      aks_ingress = {
        name            = "snet-clusteringressservices"
        cidr            = ["10.240.4.0/28"]
        nsg_key         = "azure_kubernetes_cluster_nsg"
        route_table_key = "default_to_firewall_re1"
      }
      application_gateway = {
        name    = "snet-applicationgateway"
        cidr    = ["10.240.4.16/28"]
        nsg_key = "application_gateway"
      }
      private_endpoints = {
        name                                           = "snet-privateendpoints"
        cidr                                           = ["10.240.4.32/27"]
        enforce_private_link_endpoint_network_policies = true
      }
    } //subnets

  }
} //vnets
