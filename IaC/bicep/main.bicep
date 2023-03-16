targetScope = 'subscription'

@description('The location to deploy the resources to')
param location string = deployment().location

@description('Azure AD Group in the identified tenant that will be granted the highly privileged cluster-admin role. If Azure RBAC is used, then this group will get a role assignment to Azure RBAC, else it will be assigned directly to the cluster\'s admin group.')
param clusterAdminAadGroupObjectId string = ''

@description('Azure AD Group in the identified tenant that will be granted the read only privileges in the a0008 namespace that exists in the cluster. This is only used when Azure RBAC is used for Kubernetes RBAC.')
param a0008NamespaceReaderAadGroupObjectId string = ''

param appGatewayListenerCertificate string

param aksIngressControllerCertificate string

var domainName = 'contoso.com'

module hub 'rg-hub/hub-default.bicep' = {
  name: 'deploy-hub'
  params: {
    resourceGroupName: 'rg-enterprise-networking-hubs'
    location: location
    subnetIpAddressSpace: [
      '10.240.0.0/16'
    ]
    hubVnetAddressSpace: '10.200.0.0/24'
    azureFirewallSubnetAddressSpace: '10.200.0.0/26'
    azureGatewaySubnetAddressSpace: '10.200.0.64/27'
    azureBastionSubnetAddressSpace: '10.200.0.96/27'
    networkSecurityGroupSecurityRules: [
      {
        name: 'AllowWebExperienceInBound'
        properties: {
          description: 'Allow our users in. Update this to be as restrictive as possible.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowControlPlaneInBound'
        properties: {
          description: 'Service Requirement. Allow control plane access. Regional Tag not yet supported.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowHealthProbesInBound'
        properties: {
          description: 'Service Requirement. Allow Health Probes.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostToHostInBound'
        properties: {
          description: 'Service Requirement. Allow Required Host to Host Communication.'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshToVnetOutBound'
        properties: {
          description: 'Allow SSH out to the VNet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '22'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowRdpToVnetOutBound'
        properties: {
          protocol: 'Tcp'
          description: 'Allow RDP out to the VNet'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '3389'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowControlPlaneOutBound'
        properties: {
          description: 'Required for control plane outbound. Regional prefix not yet supported'
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostToHostOutBound'
        properties: {
          description: 'Service Requirement. Allow Required Host to Host Communication.'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionCertificateValidationOutBound'
        properties: {
          description: 'Service Requirement. Allow Required Session and Certificate Validation.'
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '80'
          destinationAddressPrefix: 'Internet'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

module spoke 'rg-spoke/spoke.bicep' = {
  name: 'deploy-spoke'
  params: {
    resourceGroupName: 'rg-enterprise-networking-spokes'
    clusterVnetAddressSpace: '10.240.0.0/16'
    hubFwResourceId: hub.outputs.hubFwResourceId
    hubLaWorkspaceResourceId: hub.outputs.hubLaWorkspaceResourceId
    hubVnetResourceId: hub.outputs.hubVnetId
    location: location
  }
}

module registry 'rg-spoke/acr.bicep' = {
  name: 'deploy-registry'
  params: {
    location: location
    targetVnetResourceId: spoke.outputs.clusterVnetResourceId
    geoRedundancyLocation: 'northeurope'
  }
}

module clusterprereq 'rg-spoke/clusterprereq.bicep' = {
  name: 'deploay-clusterprereq'
  params: {
    aksIngressControllerCertificate: aksIngressControllerCertificate
    appGatewayListenerCertificate: appGatewayListenerCertificate
    domainName: domainName
    keyVaultPublicNetworkAccess: 'Enabled'
    location: location
    targetVnetResourceId: spoke.outputs.clusterVnetResourceId
    vNetResourceGroup: 'rg-enterprise-networking-spokes'
    resourceGroupName: 'rg-bu0001a0008'
  }
}

module cluster 'rg-spoke/cluster.bicep' = {
  name: 'deploay-cluster'
  params: {
    a0008NamespaceReaderAadGroupObjectId: a0008NamespaceReaderAadGroupObjectId
    clusterAdminAadGroupObjectId: clusterAdminAadGroupObjectId
    domainName: domainName
    gitOpsBootstrappingRepoBranch: 'main'
    gitOpsBootstrappingRepoHttpsUrl: 'https://github.com/Azure/aks-baseline-automation'
    kubernetesVersion: ''
    location: location
    targetVnetResourceId: spoke.outputs.clusterVnetResourceId
    vNetResourceGroup: 'rg-enterprise-networking-spokes'
    resourceGroupName: 'rg-bu0001a0008'
  }
  dependsOn: [
    clusterprereq
  ]
}

/*** OUTPUTS ***/

output containerRegistryName string = registry.outputs.containerRegistryName

output keyVaultName string = clusterprereq.outputs.keyVaultName

output aksIngressControllerPodManagedIdentityResourceId string = clusterprereq.outputs.aksIngressControllerPodManagedIdentityResourceId

output aksClusterName string = cluster.outputs.aksClusterName

output hubVnetId string = hub.outputs.hubVnetId

