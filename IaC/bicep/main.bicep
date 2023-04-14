targetScope = 'subscription'

@description('Name of the hub resource group')
param hubResourceGroupName string

@description('Name of the spoke resource group')
param spokeResourceGroupName string

@description('Name of the AKS resource group')
param aksResourceGroupName string

@description('AKS Service, Node Pool, and supporting services (KeyVault, App Gateway, etc) region. This needs to be the same region as the vnet provided in these parameters.')
param location string

@description('For Azure resources that support native geo-redunancy, provide the location the redundant service will have its secondary. Should be different than the location parameter and ideally should be a paired region - https://learn.microsoft.com/azure/best-practices-availability-paired-regions. This region does not need to support availability zones.')
param geoRedundancyLocation string

@description('Subnet address prefixes for all AKS clusters nodepools in all attached spokes to allow necessary outbound traffic through the firewall.')
@minLength(1)
param subnetIpAddressSpace array

@description('Optional. Array of Security Rules to deploy to the Network Security Group. When not provided, an NSG including only the built-in roles will be deployed.')
param networkSecurityGroupSecurityRules array = []

@description('A /24 to contain the regional firewall, management, and gateway subnet')
@minLength(10)
@maxLength(18)
param hubVnetAddressSpace string

@description('A /26 under the VNet Address Space for the regional Azure Firewall')
@minLength(10)
@maxLength(18)
param azureFirewallSubnetAddressSpace string

@description('A /27 under the VNet Address Space for our regional On-Prem Gateway')
@minLength(10)
@maxLength(18)
param azureGatewaySubnetAddressSpace string

@description('A /27 under the VNet Address Space for regional Azure Bastion')
@minLength(10)
@maxLength(18)
param azureBastionSubnetAddressSpace string

@description('A /16 to contain the cluster')
@minLength(10)
@maxLength(18)
param clusterVnetAddressSpace string

@description('IP ranges authorized to contact the Kubernetes API server. Passing an empty array will result in no IP restrictions. If any are provided, remember to also provide the public IP of the egress Azure Firewall otherwise your nodes will not be able to talk to the API server (e.g. Flux).')
param clusterAuthorizedIPRanges array = []

@description('Key Vault public network access.')
param keyVaultPublicNetworkAccess string

param kubernetesVersion string

@description('Domain name to use for App Gateway and AKS ingress.')
param domainName string

@description('Your cluster will be bootstrapped from this git repo.')
@minLength(9)
param gitOpsBootstrappingRepoHttpsUrl string

@description('You cluster will be bootstrapped from this branch in the identifed git repo.')
@minLength(1)
param gitOpsBootstrappingRepoBranch string

@description('Azure AD Group in the identified tenant that will be granted the highly privileged cluster-admin role. If Azure RBAC is used, then this group will get a role assignment to Azure RBAC, else it will be assigned directly to the cluster\'s admin group.')
param clusterAdminAadGroupObjectId string

@description('Azure AD Group in the identified tenant that will be granted the read only privileges in the a0008 namespace that exists in the cluster. This is only used when Azure RBAC is used for Kubernetes RBAC.')
param a0008NamespaceReaderAadGroupObjectId string

@description('Your AKS control plane Cluster API authentication tenant')
param k8sControlPlaneAuthorizationTenantId string = subscription().tenantId

param appGatewayListenerCertificate string

param aksIngressControllerCertificate string

module hub 'rg-hub/hub-default.bicep' = {
  name: 'deploy-hub'
  params: {
    resourceGroupName: hubResourceGroupName
    location: location
    subnetIpAddressSpace: subnetIpAddressSpace
    hubVnetAddressSpace: hubVnetAddressSpace
    azureFirewallSubnetAddressSpace: azureFirewallSubnetAddressSpace
    azureGatewaySubnetAddressSpace: azureGatewaySubnetAddressSpace
    azureBastionSubnetAddressSpace: azureBastionSubnetAddressSpace
    networkSecurityGroupSecurityRules: networkSecurityGroupSecurityRules
  }
}

module spoke 'rg-spoke/spoke.bicep' = {
  name: 'deploy-spoke'
  params: {
    resourceGroupName: spokeResourceGroupName
    clusterVnetAddressSpace: clusterVnetAddressSpace
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
    geoRedundancyLocation: geoRedundancyLocation
    resourceGroupName: spokeResourceGroupName
  }
}

module clusterprereq 'rg-spoke/clusterprereq.bicep' = {
  name: 'deploay-clusterprereq'
  params: {
    aksIngressControllerCertificate: aksIngressControllerCertificate
    appGatewayListenerCertificate: appGatewayListenerCertificate
    domainName: domainName
    keyVaultPublicNetworkAccess: keyVaultPublicNetworkAccess
    location: location
    targetVnetResourceId: spoke.outputs.clusterVnetResourceId
    vNetResourceGroup: spokeResourceGroupName
    resourceGroupName: aksResourceGroupName
  }
}

module cluster 'rg-spoke/cluster.bicep' = {
  name: 'deploay-cluster'
  params: {
    a0008NamespaceReaderAadGroupObjectId: a0008NamespaceReaderAadGroupObjectId
    clusterAdminAadGroupObjectId: clusterAdminAadGroupObjectId
    domainName: domainName
    gitOpsBootstrappingRepoBranch: gitOpsBootstrappingRepoBranch
    gitOpsBootstrappingRepoHttpsUrl: gitOpsBootstrappingRepoHttpsUrl
    kubernetesVersion: kubernetesVersion
    location: location
    targetVnetResourceId: spoke.outputs.clusterVnetResourceId
    vNetResourceGroup: spokeResourceGroupName
    resourceGroupName: aksResourceGroupName
    clusterAuthorizedIPRanges: clusterAuthorizedIPRanges
    k8sControlPlaneAuthorizationTenantId: k8sControlPlaneAuthorizationTenantId
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
