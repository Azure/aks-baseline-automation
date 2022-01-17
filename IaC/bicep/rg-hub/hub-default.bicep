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

// @description('A /24 to contain the regional firewall, management, and gateway subnet')
// @minLength(10)
// @maxLength(18)
// param hubVnetAddressSpace string = '10.200.0.0/24'

// @description('A /26 under the VNet Address Space for the regional Azure Firewall')
// @minLength(10)
// @maxLength(18)
// param azureFirewallSubnetAddressSpace string = '10.200.0.0/26'

// @description('A /27 under the VNet Address Space for our regional On-Prem Gateway')
// @minLength(10)
// @maxLength(18)
// param azureGatewaySubnetAddressSpace string = '10.200.0.64/27'

// @description('A /27 under the VNet Address Space for regional Azure Bastion')
// @minLength(10)
// @maxLength(18)
// param azureBastionSubnetAddressSpace string = '10.200.0.96/27'

// var baseFwPipName = 'pip-fw-${location}'
// var hubFwPipNames_var = [
//   '${baseFwPipName}-default'
//   '${baseFwPipName}-01'
//   '${baseFwPipName}-02'
// ]
var rgName_var = 'rg-${location}'
// var hubFwName_var = 'fw-${location}'
// var fwPoliciesBaseName_var = 'fw-policies-base'
// var fwPoliciesName_var = 'fw-policies-${location}'
//var hubVNetName_var = 'vnet-${location}-hub'
// var bastionNetworkNsgName_var = 'nsg-${location}-bastion'
var hubLaName_var = 'test' //'la-hub-${location}-${uniqueString(hubVnetName.id)}'

module rg '../CARML/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: rgName_var
  params:{
    name: resourceGroupName
    location: location
  }
}

module hubLa '../CARML/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  name: hubLaName_var
  params:{
    name: hubLaName_var
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

// resource bastionNetworkNsgName 'Microsoft.Network/networkSecurityGroups@2020-05-01' = {
//   name: bastionNetworkNsgName_var
//   location: location
//   properties: {
//     securityRules: [
//       {
//         name: 'AllowWebExperienceInBound'
//         properties: {
//           description: 'Allow our users in. Update this to be as restrictive as possible.'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           sourceAddressPrefix: 'Internet'
//           destinationPortRange: '443'
//           destinationAddressPrefix: '*'
//           access: 'Allow'
//           priority: 100
//           direction: 'Inbound'
//         }
//       }
//       {
//         name: 'AllowControlPlaneInBound'
//         properties: {
//           description: 'Service Requirement. Allow control plane access. Regional Tag not yet supported.'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           sourceAddressPrefix: 'GatewayManager'
//           destinationPortRange: '443'
//           destinationAddressPrefix: '*'
//           access: 'Allow'
//           priority: 110
//           direction: 'Inbound'
//         }
//       }
//       {
//         name: 'AllowHealthProbesInBound'
//         properties: {
//           description: 'Service Requirement. Allow Health Probes.'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           sourceAddressPrefix: 'AzureLoadBalancer'
//           destinationPortRange: '443'
//           destinationAddressPrefix: '*'
//           access: 'Allow'
//           priority: 120
//           direction: 'Inbound'
//         }
//       }
//       {
//         name: 'AllowBastionHostToHostInBound'
//         properties: {
//           description: 'Service Requirement. Allow Required Host to Host Communication.'
//           protocol: '*'
//           sourcePortRange: '*'
//           sourceAddressPrefix: 'VirtualNetwork'
//           destinationPortRanges: [
//             '8080'
//             '5701'
//           ]
//           destinationAddressPrefix: 'VirtualNetwork'
//           access: 'Allow'
//           priority: 130
//           direction: 'Inbound'
//         }
//       }
//       {
//         name: 'DenyAllInBound'
//         properties: {
//           protocol: '*'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '*'
//           destinationAddressPrefix: '*'
//           access: 'Deny'
//           priority: 1000
//           direction: 'Inbound'
//         }
//       }
//       {
//         name: 'AllowSshToVnetOutBound'
//         properties: {
//           description: 'Allow SSH out to the VNet'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '22'
//           destinationAddressPrefix: 'VirtualNetwork'
//           access: 'Allow'
//           priority: 100
//           direction: 'Outbound'
//         }
//       }
//       {
//         name: 'AllowRdpToVnetOutBound'
//         properties: {
//           protocol: 'Tcp'
//           description: 'Allow RDP out to the VNet'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '3389'
//           destinationAddressPrefix: 'VirtualNetwork'
//           access: 'Allow'
//           priority: 110
//           direction: 'Outbound'
//         }
//       }
//       {
//         name: 'AllowControlPlaneOutBound'
//         properties: {
//           description: 'Required for control plane outbound. Regional prefix not yet supported'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '443'
//           destinationAddressPrefix: 'AzureCloud'
//           access: 'Allow'
//           priority: 120
//           direction: 'Outbound'
//         }
//       }
//       {
//         name: 'AllowBastionHostToHostOutBound'
//         properties: {
//           description: 'Service Requirement. Allow Required Host to Host Communication.'
//           protocol: '*'
//           sourcePortRange: '*'
//           sourceAddressPrefix: 'VirtualNetwork'
//           destinationPortRanges: [
//             '8080'
//             '5701'
//           ]
//           destinationAddressPrefix: 'VirtualNetwork'
//           access: 'Allow'
//           priority: 130
//           direction: 'Outbound'
//         }
//       }
//       {
//         name: 'AllowBastionCertificateValidationOutBound'
//         properties: {
//           description: 'Service Requirement. Allow Required Session and Certificate Validation.'
//           protocol: '*'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '80'
//           destinationAddressPrefix: 'Internet'
//           access: 'Allow'
//           priority: 140
//           direction: 'Outbound'
//         }
//       }
//       {
//         name: 'DenyAllOutBound'
//         properties: {
//           protocol: '*'
//           sourcePortRange: '*'
//           sourceAddressPrefix: '*'
//           destinationPortRange: '*'
//           destinationAddressPrefix: '*'
//           access: 'Deny'
//           priority: 1000
//           direction: 'Outbound'
//         }
//       }
//     ]
//   }
// }

// resource bastionNetworkNsgName_Microsoft_Insights_default 'Microsoft.Network/networkSecurityGroups/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${bastionNetworkNsgName_var}/Microsoft.Insights/default'
//   properties: {
//     workspaceId: hubLaName.id
//     logs: [
//       {
//         category: 'NetworkSecurityGroupEvent'
//         enabled: true
//       }
//       {
//         category: 'NetworkSecurityGroupRuleCounter'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     bastionNetworkNsgName
//   ]
// }

// resource hubVnetName 'Microsoft.Network/virtualNetworks@2020-05-01' = {
//   name: hubVNetName_var
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         hubVnetAddressSpace
//       ]
//     }
//     subnets: [
//       {
//         name: 'AzureFirewallSubnet'
//         properties: {
//           addressPrefix: azureFirewallSubnetAddressSpace
//         }
//       }
//       {
//         name: 'GatewaySubnet'
//         properties: {
//           addressPrefix: azureGatewaySubnetAddressSpace
//         }
//       }
//       {
//         name: 'AzureBastionSubnet'
//         properties: {
//           addressPrefix: azureBastionSubnetAddressSpace
//           networkSecurityGroup: {
//             id: bastionNetworkNsgName.id
//           }
//         }
//       }
//     ]
//   }
// }

// resource hubVnetName_Microsoft_Insights_default 'Microsoft.Network/virtualNetworks/providers/diagnosticSettings@2017-05-01-preview' = {
//   name: '${hubVNetName_var}/Microsoft.Insights/default'
//   properties: {
//     workspaceId: hubLaName.id
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: [
//     hubVnetName
//   ]
// }

// resource hubFwPipNames 'Microsoft.Network/publicIpAddresses@2020-05-01' = [for item in hubFwPipNames_var: {
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
//   name: fwPoliciesBaseName_var
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
//   name: fwPoliciesName_var
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
//   name: hubFwName_var
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
//         name: hubFwPipNames_var[0]
//         properties: {
//           subnet: {
//             id: resourceId('Microsoft.Network/virtualNetworks/subnets', hubVNetName_var, 'AzureFirewallSubnet')
//           }
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames_var[0])
//           }
//         }
//       }
//       {
//         name: hubFwPipNames_var[1]
//         properties: {
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames_var[1])
//           }
//         }
//       }
//       {
//         name: hubFwPipNames_var[2]
//         properties: {
//           publicIPAddress: {
//             id: resourceId('Microsoft.Network/publicIpAddresses', hubFwPipNames_var[2])
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
//   name: '${hubFwName_var}/Microsoft.Insights/default'
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
