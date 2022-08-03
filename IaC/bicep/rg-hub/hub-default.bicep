targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'rg-enterprise-networking-hubs'

@description('The hub\'s regional affinity. All resources tied to this hub will also be homed in this region. The network team maintains this approved regional list which is a subset of zones with Availability Zone support.')
@allowed([
  'australiaeast'
  'canadacentral'
  'centralus'
  'eastus'
  'eastus2'
  'westus2'
  'francecentral'
  'germanywestcentral'
  'northeurope'
  'southafricanorth'
  'southcentralus'
  'uksouth'
  'westeurope'
  'japaneast'
  'southeastasia'
])
param location string

@description('Subnet address prefixes for all AKS clusters nodepools in all attached spokes to allow necessary outbound traffic through the firewall.')
@minLength(1)
param subnetIpAddressSpace array

@description('Optional. Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed.')
param networkSecurityGroupSecurityRules array = []

@description('A /24 to contain the regional firewall, management, and gateway subnet')
@minLength(10)
@maxLength(18)
param hubVnetAddressSpace string = '10.200.0.0/24'

@description('A /26 under the VNet Address Space for the regional Azure Firewall')
@minLength(10)
@maxLength(18)
param azureFirewallSubnetAddressSpace string = '10.200.0.0/26'

@description('A /27 under the VNet Address Space for our regional On-Prem Gateway')
@minLength(10)
@maxLength(18)
param azureGatewaySubnetAddressSpace string = '10.200.0.64/27'

@description('A /27 under the VNet Address Space for regional Azure Bastion')
@minLength(10)
@maxLength(18)
param azureBastionSubnetAddressSpace string = '10.200.0.96/27'

var baseFwPipName = 'pip-fw-${location}'
var hubFwPipNames = [
  '${baseFwPipName}-default'
  '${baseFwPipName}-01'
  '${baseFwPipName}-02'
]

var hubFwName = 'fw-${location}'
var fwPoliciesBaseName = 'fw-policies-base'
var fwPoliciesName = 'fw-policies-${location}'
var hubVNetName = 'vnet-${location}-hub'
var bastionNetworkNsgName = 'nsg-${location}-bastion'
var hubLaName = 'la-hub-${location}-${uniqueString(resourceId('Microsoft.Network/virtualNetworks', hubVNetName))}'
var ipgNodepoolSubnetName = 'ipg-nodepool-ipaddresses'

var networkRuleCollectionGroup = [
  {
    ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
    name: 'AKS-Global-Requirements'
    priority: 200
    action: {
      type: 'Allow'
    }
    rules: [
      {
        ruleType: 'NetworkRule'
        name: 'pods-to-api-server-connectivity'
        description: 'This allows pods to communicate with the API server. Ensure your API server\'s allowed IP ranges support all of this firewall\'s public IPs.'
        ipProtocols: [
          'TCP'
        ]
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
        destinationAddresses: [
          'AzureCloud.${location}' // Ideally you'd list your AKS server endpoints in appliction rules, instead of this wide-ranged rule
        ]
        destinationIpGroups: []
        destinationFqdns: []
        destinationPorts: [
          '443'
        ]
      }
      {
        ruleType: 'NetworkRule'
        name: 'pods-to-api-server-udp'
        description: 'This allows pods to communicate with the API server. Ensure your API server\'s allowed IP ranges support all of this firewall\'s public IPs.'
        ipProtocols: [
          'UDP'
        ]
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
        destinationAddresses: [
          'AzureCloud.${location}' // Ideally you'd list your AKS server endpoints in appliction rules, instead of this wide-ranged rule
        ]
        destinationIpGroups: []
        destinationFqdns: []
        destinationPorts: [
          '1194'
        ]
      }
    ]
  }
]

var applicationRuleCollectionGroup = [
  {
    ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
    name: 'AKS-Global-Requirements'
    priority: 200
    action: {
      type: 'Allow'
    }
    rules: [
      {
        ruleType: 'ApplicationRule'
        name: 'azure-monitor-addon'
        description: 'Supports required communication for the Azure Monitor addon in AKS'
        protocols: [
          {
            protocolType: 'Https'
            port: 443
          }
        ]
        fqdnTags: []
        webCategories: []
        targetFqdns: [
          '*.ods.opinsights.azure.com'
          '*.oms.opinsights.azure.com'
          '${location}.monitoring.azure.com'
        ]
        targetUrls: []
        destinationAddresses: []
        terminateTLS: false
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
      }
      {
        ruleType: 'ApplicationRule'
        name: 'azure-policy-addon'
        description: 'Supports required communication for the Azure Policy addon in AKS'
        protocols: [
          {
            protocolType: 'Https'
            port: 443
          }
        ]
        fqdnTags: []
        webCategories: []
        targetFqdns: [
          'data.policy.${environment().suffixes.storage}'
          'store.policy.${environment().suffixes.storage}'
        ]
        targetUrls: []
        destinationAddresses: []
        terminateTLS: false
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
      }
      {
        ruleType: 'ApplicationRule'
        name: 'service-requirements'
        description: 'Supports required core AKS functionality. Could be replaced with individual rules if added granularity is desired.'
        protocols: [
          {
            protocolType: 'Https'
            port: 443
          }
        ]
        fqdnTags: [
          'AzureKubernetesService'
        ]
        webCategories: []
        targetFqdns: []
        targetUrls: []
        destinationAddresses: []
        terminateTLS: false
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
      }
    ]
  }
  {
    ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
    name: 'GitOps-Traffic'
    priority: 300
    action: {
      type: 'Allow'
    }
    rules: [
      {
        ruleType: 'ApplicationRule'
        name: 'github-origin'
        description: 'Supports pulling gitops configuration from GitHub.'
        protocols: [
          {
            protocolType: 'Https'
            port: 443
          }
        ]
        fqdnTags: []
        webCategories: []
        targetFqdns: [
          'github.com'
          'api.github.com'
          'raw.githubusercontent.com'
        ]
        targetUrls: []
        destinationAddresses: []
        terminateTLS: false
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
      }
      {
        ruleType: 'ApplicationRule'
        name: 'flux-extension-runtime-requirements'
        description: 'Supports required communication for the Flux v2 extension operate and contains allowances for our applications deployed to the cluster.'
        protocols: [
          {
            protocolType: 'Https'
            port: 443
          }
        ]
        fqdnTags: []
        webCategories: []
        targetFqdns: [
          '${location}.dp.kubernetesconfiguration.azure.com'
          'mcr.microsoft.com'
          '${split(environment().resourceManager, '/')[2]}' // Prevent the linter from getting upset at management.azure.com - https://github.com/Azure/bicep/issues/3080
          '${split(environment().authentication.loginEndpoint, '/')[2]}' // Prevent the linter from getting upset at login.microsoftonline.com
          '*.blob.${environment().suffixes.storage}' // required for the extension installer to download the helm chart install flux. This storage account is not predictable, but does look like eusreplstore196 for example.
          'azurearcfork8s.azurecr.io' // required for a few of the images installed by the extension.
          '*.docker.io' // Only required if you use the default bootstrapping manifests included in this repo. Kured is sourced from here by default.
          '*.docker.com' // Only required if you use the default bootstrapping manifests included in this repo. Kured is sourced from here by default.
        ]
        targetUrls: []
        destinationAddresses: []
        terminateTLS: false
        sourceAddresses: []
        sourceIpGroups: [
          ipgNodepoolSubnet.outputs.resourceId
        ]
      }
    ]
  }
]

module rg '../CARML/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: resourceGroupName
  params: {
    name: resourceGroupName
    location: location
  }
}

module hubLa '../CARML/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  name: hubLaName
  params: {
    name: hubLaName
    location: location
    serviceTier: 'PerGB2018'
    dataRetention: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module bastionNsg '../CARML/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: bastionNetworkNsgName
  params: {
    name: bastionNetworkNsgName
    location: location
    securityRules: networkSecurityGroupSecurityRules
    diagnosticWorkspaceId: hubLa.outputs.resourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module hubVNet '../CARML/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: hubVNetName
  params: {
    name: hubVNetName
    location: location
    addressPrefixes: array(hubVnetAddressSpace)
    diagnosticWorkspaceId: hubLa.outputs.resourceId
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: azureFirewallSubnetAddressSpace
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: azureGatewaySubnetAddressSpace
      }
      {
        name: 'AzureBastionSubnet'
        addressPrefix: azureBastionSubnetAddressSpace
        networkSecurityGroupName: bastionNsg.outputs.name
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

// This holds IP addresses of known nodepool subnets in spokes.
module ipgNodepoolSubnet '../CARML/Microsoft.Network/ipGroups/deploy.bicep' = {
  name: ipgNodepoolSubnetName
  params: {
    name: ipgNodepoolSubnetName
    ipAddresses: subnetIpAddressSpace
    location: location
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module hubFwPips '../CARML/Microsoft.Network/publicIPAddresses/deploy.bicep' = [for item in hubFwPipNames: {
  name: item
  params: {
    name: item
    location: location
    skuName: 'Standard'
    publicIPAllocationMethod: 'Static'
    zones: [
      '1'
      '2'
      '3'
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}]

module fwPoliciesBase '../CARML/Microsoft.Network/firewallPolicies/deploy.bicep' = {
  name: fwPoliciesBaseName
  params: {
    name: fwPoliciesBaseName
    location: location
    tier: 'Premium'
    threatIntelMode: 'Deny'
    mode: 'Deny'
    ipAddresses: []
    enableProxy: true
    servers: []
    ruleCollectionGroups: [
      {
        name: 'DefaultNetworkRuleCollectionGroup'
        priority: 200
        ruleCollections: [
          {
            ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
            action: {
              type: 'Allow'
            }
            rules: [
              {
                ruleType: 'NetworkRule'
                name: 'DNS'
                description: 'Allow DNS outbound (for simplicity, adjust as needed)'
                ipProtocols: [
                  'UDP'
                ]
                sourceAddresses: [
                  '*'
                ]
                sourceIpGroups: []
                destinationAddresses: [
                  '*'
                ]
                destinationIpGroups: []
                destinationFqdns: []
                destinationPorts: [
                  '53'
                ]
              }
            ]
            name: 'org-wide-allowed'
            priority: 100
          }
        ]
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    ipgNodepoolSubnet
  ]
}

module fwPolicies '../CARML/Microsoft.Network/firewallPolicies/deploy.bicep' = {
  name: fwPoliciesName
  params: {
    name: fwPoliciesName
    location: location
    basePolicyResourceId: fwPoliciesBase.outputs.resourceId
    tier: 'Premium'
    threatIntelMode: 'Deny'
    mode: 'Deny'
    ipAddresses: []
    enableProxy: true
    servers: []
    ruleCollectionGroups: [
      {
        name: 'DefaultDnatRuleCollectionGroup'
        priority: 100
        ruleCollections: []
      }
      {
        name: 'DefaultNetworkRuleCollectionGroup'
        priority: 200
        ruleCollections: networkRuleCollectionGroup
      }
      {
        name: 'DefaultApplicationRuleCollectionGroup'
        priority: 300
        ruleCollections: applicationRuleCollectionGroup
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    fwPoliciesBase
    ipgNodepoolSubnet
  ]
}

module hubFw '../CARML/Microsoft.Network/azureFirewalls/deploy.bicep' = {
  name: hubFwName
  scope: resourceGroup(resourceGroupName)
  params: {
    name: hubFwName
    location: location
    vNetId: hubVNet.outputs.resourceId
    zones: [
      '1'
      '2'
      '3'
    ]
    azureSkuName: 'AZFW_VNet'
    azureSkuTier: 'Premium'
    threatIntelMode: 'Deny'
    azureFirewallSubnetPublicIpId:hubFwPips[0].outputs.resourceId
    additionalPublicIpConfigurations: [
      {
        name: hubFwPipNames[1]
        publicIPAddressResourceId: hubFwPips[1].outputs.resourceId
      }
      {
        name: hubFwPipNames[2]
        publicIPAddressResourceId: hubFwPips[2].outputs.resourceId
      }
    ]
    natRuleCollections: []
    networkRuleCollections: []
    applicationRuleCollections: []
    firewallPolicyId: fwPolicies.outputs.resourceId
    diagnosticWorkspaceId: hubLa.outputs.resourceId
  }
  dependsOn: [
    rg
    fwPoliciesBase
    fwPolicies
    ipgNodepoolSubnet
  ]
}

output hubVnetId string = hubVNet.outputs.resourceId
output hubLaWorkspaceResourceId string = hubLa.outputs.resourceId
output hubFwResourceId string = hubFw.outputs.resourceId
