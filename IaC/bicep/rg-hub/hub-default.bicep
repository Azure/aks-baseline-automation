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

// var baseFwPipName = 'pip-fw-${location}'
// var hubFwPipNames = [
//   '${baseFwPipName}-default'
//   '${baseFwPipName}-01'
//   '${baseFwPipName}-02'
// ]

// var hubFwName = 'fw-${location}'
// var fwPoliciesBaseName = 'fw-policies-base'
// var fwPoliciesName = 'fw-policies-${location}'
var hubVNetName = 'vnet-${location}-hub'
var bastionNetworkNsgName = 'nsg-${location}-bastion'
var hubLaName = 'la-hub-${location}-${uniqueString(resourceId('Microsoft.Network/virtualNetworks', hubVNetName))}'

module rg '../CARML/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: resourceGroupName
  params:{
    name: resourceGroupName
    location: location
  }
}

module hubLa '../CARML/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  name: hubLaName
  params:{
    name: hubLaName
    location: location
    serviceTier: 'PerGB2018'
    dataRetention: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn:[
    rg
  ]
}

module bastionNsg '../CARML/Microsoft.Network/networkSecurityGroups/deploy.bicep' = {
  name: bastionNetworkNsgName
  params:{
    name: bastionNetworkNsgName
    location: location
    networkSecurityGroupSecurityRules: networkSecurityGroupSecurityRules
    diagnosticWorkspaceId: hubLa.outputs.logAnalyticsResourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn:[
    rg
  ]
}

module hubVNet '../CARML/Microsoft.Network/virtualNetworks/deploy.bicep' = {
  name: hubVNetName
  params:{
    name: hubVNetName
    addressPrefixes: array(hubVnetAddressSpace)
    diagnosticWorkspaceId: hubLa.outputs.logAnalyticsResourceId
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
        networkSecurityGroupName: bastionNsg.outputs.networkSecurityGroupName
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn:[
    rg
  ]
}

// resource hubFwPipNames 'Microsoft.Network/publicIpAddresses@2020-05-01' = [for item in hubFwPipNames: {
//   name: item
//   location: location
//   sku: {
//     name: 'Standard'
//   }
//   properties: {
//     publicIPAllocationMethod: 'Static'
//     idleTimeoutInMinutes: 4
//     publicIPAddressVersion: 'IPv4'
//   }
// }]

// resource fwPoliciesBaseName 'Microsoft.Network/firewallPolicies@2021-02-01' = {
//   name: fwPoliciesBaseName
//   location: location
//   properties: {
//     sku: {
//       tier: 'Standard'
//     }
//     threatIntelMode: 'Deny'
//     threatIntelWhitelist: {
//       ipAddresses: []
//     }
//     dnsSettings: {
//       servers: []
//       enableProxy: true
//     }
//   }
// }

// resource fwPoliciesBaseName_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
//   parent: fwPoliciesBaseName
//   name: 'DefaultNetworkRuleCollectionGroup'
//   location: location
//   properties: {
//     priority: 200
//     ruleCollections: [
//       {
//         ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
//         action: {
//           type: 'Allow'
//         }
//         rules: [
//           {
//             ruleType: 'NetworkRule'
//             name: 'DNS'
//             ipProtocols: [
//               'UDP'
//             ]
//             sourceAddresses: [
//               '*'
//             ]
//             sourceIpGroups: []
//             destinationAddresses: [
//               '*'
//             ]
//             destinationIpGroups: []
//             destinationFqdns: []
//             destinationPorts: [
//               '53'
//             ]
//           }
//         ]
//         name: 'org-wide-allowed'
//         priority: 100
//       }
//     ]
//   }
// }

// resource fwPoliciesName 'Microsoft.Network/firewallPolicies@2021-02-01' = {
//   name: fwPoliciesName
//   location: location
//   properties: {
//     basePolicy: {
//       id: fwPoliciesBaseName.id
//     }
//     sku: {
//       tier: 'Standard'
//     }
//     threatIntelMode: 'Deny'
//     threatIntelWhitelist: {
//       ipAddresses: []
//     }
//     dnsSettings: {
//       servers: []
//       enableProxy: true
//     }
//   }
//   dependsOn: [
//     fwPoliciesBaseName_DefaultNetworkRuleCollectionGroup
//   ]
// }

// resource fwPoliciesName_DefaultDnatRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
//   parent: fwPoliciesName
//   name: 'DefaultDnatRuleCollectionGroup'
//   location: location
//   properties: {
//     priority: 100
//     ruleCollections: []
//   }
// }

// resource fwPoliciesName_DefaultApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
//   parent: fwPoliciesName
//   name: 'DefaultApplicationRuleCollectionGroup'
//   location: location
//   properties: {
//     priority: 300
//     ruleCollections: []
//   }
//   dependsOn: [
//     fwPoliciesName_DefaultDnatRuleCollectionGroup
//   ]
// }

// resource fwPoliciesName_DefaultNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
//   parent: fwPoliciesName
//   name: 'DefaultNetworkRuleCollectionGroup'
//   location: location
//   properties: {
//     priority: 200
//     ruleCollections: []
//   }
//   dependsOn: [
//     fwPoliciesName_DefaultApplicationRuleCollectionGroup
//   ]
// }

// resource hubFwName 'Microsoft.Network/azureFirewalls@2020-11-01' = {
//   name: hubFwName
//   location: location
//   zones: [
//     '1'
//     '2'
//     '3'
//   ]
//   properties: {
//     additionalProperties: {}
//     sku: {
//       name: 'AZFW_VNet'
//       tier: 'Standard'
//     }
//     threatIntelMode: 'Deny'
//     ipConfigurations: [
//       {
//         name: hubFwPipNames[0]
//         properties: {
//           subnet: {
//             id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNetName, 'AzureFirewallSubnet')
//           }
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames[0])
//           }
//         }
//       }
//       {
//         name: hubFwPipNames[1]
//         properties: {
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames[1])
//           }
//         }
//       }
//       {
//         name: hubFwPipNames[2]
//         properties: {
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames[2])
//           }
//         }
//       }
//     ]
//     natRuleCollections: []
//     networkRuleCollections: []
//     applicationRuleCollections: []
//     firewallPolicy: {
//       id: fwPoliciesName.id
//     }
//   }
//   dependsOn: [
//     hubFwPipNames
//     hubVnetName
//     fwPoliciesName_DefaultNetworkRuleCollectionGroup
//   ]
// }

// resource hubFwName_Microsoft_Insights_default 'Microsoft.Network/azureFirewalls/providers/diagnosticSettings@2021-05-01-preview' = {
//   name: '${hubFwName}/Microsoft.Insights/default'
//   properties: {
//     workspaceId: hubLaName.id
//     logs: [
//       {
//         categoryGroup: 'allLogs'
//         enabled: true
//       }
//     ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     hubFwName
//   ]
// }

// output hubVnetId string = hubVnetName.id
