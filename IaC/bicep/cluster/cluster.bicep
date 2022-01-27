targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'rg-spoke'

@description('The regional network spoke VNet Resource ID that the cluster will be joined to')
@minLength(79)
param targetVnetResourceId string

// @description('Azure AD Group in the identified tenant that will be granted the highly privileged cluster-admin role. If Azure RBAC is used, then this group will get a role assignment to Azure RBAC, else it will be assigned directly to the cluster\'s admin group.')
// param clusterAdminAadGroupObjectId string

// @description('Azure AD Group in the identified tenant that will be granted the read only privileges in the a0008 namespace that exists in the cluster. This is only used when Azure RBAC is used for Kubernetes RBAC.')
// param a0008NamespaceReaderAadGroupObjectId string

// @description('Your AKS control plane Cluster API authentication tenant')
// param k8sControlPlaneAuthorizationTenantId string

@description('The certificate data for app gateway TLS termination. It is base64')
param appGatewayListenerCertificate string

@description('The Base64 encoded AKS Ingress Controller public certificate (as .crt or .cer) to be stored in Azure Key Vault as secret and referenced by Azure Application Gateway as a trusted root certificate.')
param aksIngressControllerCertificate string

// @description('IP ranges authorized to contact the Kubernetes API server. Passing an empty array will result in no IP restrictions. If any are provided, remember to also provide the public IP of the egress Azure Firewall otherwise your nodes will not be able to talk to the API server (e.g. Flux).')
// param clusterAuthorizedIPRanges array = []

@description('AKS Service, Node Pool, and supporting services (KeyVault, App Gateway, etc) region. This needs to be the same region as the vnet provided in these parameters.')
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
param location string = 'eastus2'
// param kubernetesVersion string = '1.22.4'

@description('Domain name to use for App Gateway and AKS ingress.')
param domainName string = 'contoso.com'

// @description('Your cluster will be bootstrapped from this git repo.')
// @minLength(9)
// param gitOpsBootstrappingRepoHttpsUrl string = 'https://github.com/mspnp/aks-baseline'

// @description('You cluster will be bootstrapped from this branch in the identifed git repo.')
// @minLength(1)
// param gitOpsBootstrappingRepoBranch string = 'main'

// var networkContributorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
// var monitoringMetricsPublisherRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
// var acrPullRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
// var managedIdentityOperatorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
// var virtualMachineContributorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
// var clusterAdminRoleId = 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
// var clusterReaderRoleId = '7f6c6a51-bcf8-42ba-9220-52d62157d7db'
// var serviceClusterUserRoleId = '4abbcc35-e782-43d8-92c5-2d3f1bd2253f'
var subRgUniqueString = uniqueString('aks', subscription().subscriptionId, resourceGroupName)
// var nodeResourceGroupName = 'rg-${clusterName}-nodepools'
var clusterName = 'aks-${subRgUniqueString}'
var logAnalyticsWorkspaceName = 'la-${clusterName}'
// var containerInsightsSolutionName = 'ContainerInsights(${logAnalyticsWorkspaceName})'
// var defaultAcrName = 'acraks${subRgUniqueString}'
var vNetResourceGroup = split(targetVnetResourceId, '/')[4]
var vnetName = split(targetVnetResourceId, '/')[8]
var subnetName = 'snet-clusternodes'
var vnetNodePoolSubnetResourceId = '${targetVnetResourceId}/subnets/${subnetName}'
// var vnetIngressServicesSubnetResourceId = '${targetVnetResourceId}/subnets/snet-cluster-ingressservices'
var agwName = 'apw-${clusterName}'
var akvPrivateDnsZonesName = 'privatelink.vaultcore.azure.net'
var clusterControlPlaneIdentityName = 'mi-${clusterName}-controlplane'
var keyVaultName = 'kv-${clusterName}'
var aksIngressDomainName = 'aks-ingress.${domainName}'
var aksBackendDomainName = 'bu0001a0008-00.${aksIngressDomainName}'
// var policyResourceIdAKSLinuxRestrictive = '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'
// var policyResourceIdEnforceHttpsIngress = '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
// var policyResourceIdEnforceInternalLoadBalancers = '/providers/Microsoft.Authorization/policyDefinitions/3fc4dc25-5baf-40d8-9b05-7fe74c1bc64e'
// var policyResourceIdRoRootFilesystem = '/providers/Microsoft.Authorization/policyDefinitions/df49d893-a74c-421d-bc95-c663042e5b80'
// var policyResourceIdEnforceResourceLimits = '/providers/Microsoft.Authorization/policyDefinitions/e345eecc-fa47-480f-9e88-67dcc122b164'
// var policyResourceIdEnforceImageSource = '/providers/Microsoft.Authorization/policyDefinitions/febd0533-8e55-448f-b837-bd0e06f16469'
// var policyAssignmentNameAKSLinuxRestrictive = guid(policyResourceIdAKSLinuxRestrictive, resourceGroup().name, clusterName)
// var policyAssignmentNameEnforceHttpsIngress = guid(policyResourceIdEnforceHttpsIngress, resourceGroup().name, clusterName)
// var policyAssignmentNameEnforceInternalLoadBalancers = guid(policyResourceIdEnforceInternalLoadBalancers, resourceGroup().name, clusterName)
// var policyAssignmentNameRoRootFilesystem = guid(policyResourceIdRoRootFilesystem, resourceGroup().name, clusterName)
// var policyAssignmentNameEnforceResourceLimits = guid(policyResourceIdEnforceResourceLimits, resourceGroup().name, clusterName)
// var policyAssignmentNameEnforceImageSource = guid(policyResourceIdEnforceImageSource, resourceGroup().name, clusterName)
// var isUsingAzureRBACasKubernetesRBAC = (subscription().tenantId == k8sControlPlaneAuthorizationTenantId)

module rg '../CARML/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: resourceGroupName
  params: {
    name: resourceGroupName
    location: location
  }
}

module clusterLa '../CARML/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  name: logAnalyticsWorkspaceName
  params: {
    name: logAnalyticsWorkspaceName
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

module clusterControlPlaneIdentity '../CARML/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
  name: clusterControlPlaneIdentityName
  params: {
    name: clusterControlPlaneIdentityName
    location: location
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module mi_appgateway_frontend '../CARML/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
  name: 'mi-appgateway-frontend'
  params: {
    name: 'mi-appgateway-frontend'
    location: location
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module podmi_ingress_controller '../CARML/Microsoft.ManagedIdentity/userAssignedIdentities/deploy.bicep' = {
  name: 'podmi-ingress-controller'
  params: {
    name: 'podmi-ingress-controller'
    location: location
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module keyVault '../CARML/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: keyVaultName
  params: {
    name: keyVaultName
    location: location
    accessPolicies: []
    vaultSku: 'standard'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    enableRbacAuthorization: true
    enableVaultForDeployment: false
    enableVaultForDiskEncryption: false
    enableVaultForTemplateDeployment: false
    enableSoftDelete: true
    diagnosticWorkspaceId: clusterLa.outputs.logAnalyticsResourceId
    secrets: [
      {
        name: 'gateway-public-cert'
        value: appGatewayListenerCertificate
      }
      {
        name: 'appgw-ingress-internal-aks-ingress-tls'
        value: aksIngressControllerCertificate
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User (preview)'
        principalIds: [
          mi_appgateway_frontend.outputs.msiPrincipalId
          podmi_ingress_controller.outputs.msiPrincipalId
        ]
      }
      {
        roleDefinitionIdOrName: 'Key Vault Reader (preview)'
        principalIds: [
          mi_appgateway_frontend.outputs.msiPrincipalId
          podmi_ingress_controller.outputs.msiPrincipalId
        ]
      }
    ]
    privateEndpoints: [
      {
        name: 'nodepools-to-akv'
        subnetResourceId: vnetNodePoolSubnetResourceId
        service: 'vault'
        privateDnsZoneResourceIds: [
          akvPrivateDnsZones.outputs.privateDnsZoneResourceId
        ]
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    mi_appgateway_frontend
    podmi_ingress_controller
  ]
}

module akvPrivateDnsZones '../CARML/Microsoft.Network/privateDnsZones/deploy.bicep' = {
  name: akvPrivateDnsZonesName
  params: {
    name: akvPrivateDnsZonesName
    location: 'global'
    virtualNetworkLinks: [
      {
        name: 'to_${vnetName}'
        virtualNetworkResourceId: targetVnetResourceId
        registrationEnabled: false
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module aksIngressDomain '../CARML/Microsoft.Network/privateDnsZones/deploy.bicep' = {
  name: aksIngressDomainName
  params: {
    name: aksIngressDomainName
    location: 'global'
    virtualNetworkLinks: [
      {
        name: 'to_${vnetName}'
        virtualNetworkResourceId: targetVnetResourceId
        registrationEnabled: false
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

// resource aksIngressDomain_bu0001a0008_00 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
//   parent: aksIngressDomain
//   name: 'bu0001a0008-00'
//   properties: {
//     ttl: 3600
//     aRecords: [
//       {
//         ipv4Address: '10.240.4.4'
//       }
//     ]
//   }
// }

module agw '../CARML/Microsoft.Network/applicationGateways/deploy.bicep' = {
  name: agwName
  params: {
    name: agwName
    location: location
    userAssignedIdentities: {
      '${mi_appgateway_frontend.outputs.msiResourceId}': {}
    }
    // zones: pickZones('Microsoft.Network', 'applicationGateways', location, 3)
    sku: 'WAF_v2'
    // sslPolicy: {
    //   policyType: 'Custom'
    //   cipherSuites: [
    //     'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
    //     'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
    //   ]
    //   minProtocolVersion: 'TLSv1_2'
    // }
    gatewayIpConfigurationName: 'apw-ip-configuration' //subnet id: '${targetVnetResourceId}/subnets/snet-applicationgateway'
    // trustedRootCertificates: [
    //   {
    //     name: 'root-cert-wildcard-aks-ingress'
    //     properties: {
    //       keyVaultSecretId: '${keyVaultName.properties.vaultUri}secrets/appgw-ingress-internal-aks-ingress-tls'
    //     }
    //   }
    // ]
    backendHttpConfigurations: [
      {
        backendHttpConfigurationName: 'aks-ingress-backendpool-httpsettings'
        port: 443
        protocol: 'https'
        cookieBasedAffinity: 'Disabled'
        pickHostNameFromBackendAddress: true
        probeEnabled: false
        //requestTimeout: 20
        // trustedRootCertificates: [
        //   {
        //      id: resourceId('Microsoft.Network/applicationGateways/trustedRootCertificates', agwName, 'root-cert-wildcard-aks-ingress')
        //   }
        // ]
      }
    ]
    frontendPublicIpResourceId: '${subscription().id}/resourceGroups/${vNetResourceGroup}/providers/Microsoft.Network/publicIpAddresses/pip-BU0001A0008-00'
    frontendHttpsListeners: [
      {
        frontendListenerName: 'port-443'
        frontendIPType: 'Public'
        port: 443
      }
    ]
    // httpListeners: [
    //   {
    //     name: 'listener-https'
    //     properties: {
    //       frontendIPConfiguration: {
    //         id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agwName_var, 'apw-frontend-ip-configuration')
    //       }
    //       frontendPort: {
    //         id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agwName_var, 'port-443')
    //       }
    //       protocol: 'Https'
    //       sslCertificate: {
    //         id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', agwName_var, '${agwName_var}-ssl-certificate')
    //       }
    //       hostName: 'bicycle.${domainName}'
    //       hostNames: []
    //       requireServerNameIndication: true
    //     }
    //   }
    // ]
    backendPools: [
      {
        backendPoolName: aksBackendDomainName
        backendAddresses: [
          {
            fqdn: aksBackendDomainName
          }
        ]
      }
    ]
    // autoscaleConfiguration: {
    //   minCapacity: 0
    //   maxCapacity: 10
    // }
    vNetName: vnetName
    subnetName: subnetName
    http2Enabled: true
    sslCertificateName: '${agwName}-ssl-certificate'
    sslCertificateKeyVaultSecretId: '${keyVault.outputs.keyVaultUrl}secrets/gateway-public-cert'
    // webApplicationFirewallConfiguration: {
    //   enabled: true
    //   firewallMode: 'Prevention'
    //   ruleSetType: 'OWASP'
    //   ruleSetVersion: '3.2'
    //   exclusions: []
    //   fileUploadLimitInMb: 10
    //   disabledRuleGroups: []
    // }
    probes: [
      {
        backendHttpConfigurationName: 'probe-${aksBackendDomainName}' //will be altered by module
        protocol: 'Https'
        path: '/favicon.ico'
        interval: 30
        timeout: 30
        unhealthyThreshold: 3
        //pickHostNameFromBackendHttpSettings: true
        minServers: 0
        //match: {}
        //modules expect host
      }
    ]
    routingRules: [
      {
        frontendListenerName: 'listener-https'
        backendPoolName: aksBackendDomainName
        backendHttpConfigurationName: 'aks-ingress-backendpool-httpsettings'
      }
    ]
    diagnosticWorkspaceId: clusterLa.outputs.logAnalyticsResourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    keyVault
  ]
}

output aksClusterName string = clusterName
output aksIngressControllerPodManagedIdentityResourceId string = podmi_ingress_controller.outputs.msiResourceId
// output aksIngressControllerPodManagedIdentityClientId string = podmi_ingress_controller.outputs.msiClientId
output keyVaultName string = keyVaultName
