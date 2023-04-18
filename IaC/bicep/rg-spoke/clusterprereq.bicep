targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'rg-bu0001a0008'

param vNetResourceGroup string = 'rg-enterprise-networking-spokes'

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
param location string

@description('Key Vault public network access.')
param keyVaultPublicNetworkAccess string

@description('Domain name to use for App Gateway and AKS ingress.')
param domainName string

@description('The regional network spoke VNet Resource ID that the cluster will be joined to')
@minLength(79)
param targetVnetResourceId string

param appGatewayListenerCertificate string
param aksIngressControllerCertificate string

var subRgUniqueString = uniqueString('aks', subscription().subscriptionId, resourceGroupName, location)
var clusterName = 'aks-${subRgUniqueString}'
var logAnalyticsWorkspaceName = 'la-${clusterName}'
var agwName = 'apw-${clusterName}'
var akvPrivateDnsZonesName = 'privatelink.vaultcore.azure.net'
var aksIngressDomainName = 'aks-ingress.${domainName}'
var aksBackendDomainName = 'bu0001a0008-00.${aksIngressDomainName}'
var vnetName = split(targetVnetResourceId, '/')[8]
var clusterNodesSubnetName = 'snet-clusternodes'
var vnetNodePoolSubnetResourceId = '${targetVnetResourceId}/subnets/${clusterNodesSubnetName}'
var keyVaultName = 'kv-${clusterName}'

module rg '../CARML/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: 'resourceGroup'
  params: {
    name: resourceGroupName
    location: location
  }
}

// module akvCertFrontend './cert.bicep' = {
//   name: 'CreateFeKvCert'
//   params: {
//     location: location
//     akvName: keyVault.name
//     certificateNameFE: 'frontendCertificate'
//     certificateCommonNameFE: 'bicycle.${domainName}'
//     certificateNameBE: 'backendCertificate'
//     certificateCommonNameBE: '*.aks-ingress.${domainName}'
//   }
//   scope: resourceGroup(resourceGroupName)
// }

module clusterLa '../CARML/Microsoft.OperationalInsights/workspaces/deploy.bicep' = {
  name: 'logAnalyticsWorkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    serviceTier: 'PerGB2018'
    dataRetention: 30
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    // savedSearches: [
    //   {
    //     name: 'AllPrometheus'
    //     category: 'Prometheus'
    //     displayName: 'All collected Prometheus information'
    //     query: 'InsightsMetrics | where Namespace == \'prometheus\''
    //   }
    //   {
    //     name: 'NodeRebootRequested'
    //     category: 'Prometheus'
    //     displayName: 'Nodes reboot required by kured'
    //     query: 'InsightsMetrics | where Namespace == \'prometheus\' and Name == \'kured_reboot_required\' | where Val > 0'
    //   }
    // ]
    gallerySolutions: [
      // {
      //   name: 'ContainerInsights'
      //   product: 'OMSGallery'
      //   publisher: 'Microsoft'
      // }
      {
        name: 'KeyVaultAnalytics'
        product: 'OMSGallery'
        publisher: 'Microsoft'
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module PodFailedScheduledQuery '../CARML/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = {
  name: 'PodFailedScheduledQuery'
  params: {
    name: 'PodFailedScheduledQuery'
    location: location
    alertDescription: 'Alert on pod Failed phase.'
    severity: 3
    evaluationFrequency: 'PT5M'
    enabled: true
    windowSize: 'PT10M'
    scopes: [
      clusterLa.outputs.resourceId
    ]
    criterias: {
      allOf: [
        {
          query: '//https://learn.microsoft.com/azure/azure-monitor/insights/container-insights-alerts \r\n let endDateTime = now(); let startDateTime = ago(1h); let trendBinSize = 1m; let clusterName = "${clusterName}"; KubePodInventory | where TimeGenerated < endDateTime | where TimeGenerated >= startDateTime | where ClusterName == clusterName | distinct ClusterName, TimeGenerated | summarize ClusterSnapshotCount = count() by bin(TimeGenerated, trendBinSize), ClusterName | join hint.strategy=broadcast ( KubePodInventory | where TimeGenerated < endDateTime | where TimeGenerated >= startDateTime | distinct ClusterName, Computer, PodUid, TimeGenerated, PodStatus | summarize TotalCount = count(), PendingCount = sumif(1, PodStatus =~ "Pending"), RunningCount = sumif(1, PodStatus =~ "Running"), SucceededCount = sumif(1, PodStatus =~ "Succeeded"), FailedCount = sumif(1, PodStatus =~ "Failed") by ClusterName, bin(TimeGenerated, trendBinSize) ) on ClusterName, TimeGenerated | extend UnknownCount = TotalCount - PendingCount - RunningCount - SucceededCount - FailedCount | project TimeGenerated, TotalCount = todouble(TotalCount) / ClusterSnapshotCount, PendingCount = todouble(PendingCount) / ClusterSnapshotCount, RunningCount = todouble(RunningCount) / ClusterSnapshotCount, SucceededCount = todouble(SucceededCount) / ClusterSnapshotCount, FailedCount = todouble(FailedCount) / ClusterSnapshotCount, UnknownCount = todouble(UnknownCount) / ClusterSnapshotCount| summarize AggregatedValue = avg(FailedCount) by bin(TimeGenerated, trendBinSize)'
          timeAggregation: 'Average'
          metricMeasureColumn: 'AggregatedValue'
          operator: 'GreaterThan'
          threshold: 3
          failingPeriods: {
            numberOfEvaluationPeriods: 3
            minFailingPeriodsToAlert: 3
          }
        }
      ]
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    clusterLa
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

module akvPrivateDnsZones '../CARML/Microsoft.Network/privateDnsZones/deploy.bicep' = {
  name: 'akvPrivateDnsZones'
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

module keyVault '../CARML/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: 'keyVault'
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
    enableVaultForTemplateDeployment: true
    enableSoftDelete: true
    publicNetworkAccess: keyVaultPublicNetworkAccess
    diagnosticWorkspaceId: clusterLa.outputs.resourceId
    secrets: {}
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Key Vault Certificates Officer'
        principalIds: [
          mi_appgateway_frontend.outputs.principalId
          podmi_ingress_controller.outputs.principalId
        ]
      }
      {
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalIds: [
          mi_appgateway_frontend.outputs.principalId
          podmi_ingress_controller.outputs.principalId
        ]
      }
      {
        roleDefinitionIdOrName: 'Key Vault Reader'
        principalIds: [
          mi_appgateway_frontend.outputs.principalId
          podmi_ingress_controller.outputs.principalId
        ]
      }
    ]
    privateEndpoints: [
      {
        name: 'nodepools-to-akv'
        subnetResourceId: vnetNodePoolSubnetResourceId
        service: 'vault'
        privateDnsZoneGroup: {
          privateDNSResourceIds: [
            akvPrivateDnsZones.outputs.resourceId
          ]
        }
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

module frontendCert '../CARML/Microsoft.KeyVault/vaults/secrets/deploy.bicep' = {
  name: 'frontendCert'
  params: {
    value: appGatewayListenerCertificate
    keyVaultName: keyVaultName
    name: 'frontendCert'
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    keyVault
  ]
}

module backendCert '../CARML/Microsoft.KeyVault/vaults/secrets/deploy.bicep' = {
  name: 'backendCert'
  params: {
    value: aksIngressControllerCertificate
    keyVaultName: keyVaultName
    name: 'backendCert'
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    keyVault
  ]
}

module wafPolicy '../CARML/Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/deploy.bicep' = {
  name: 'waf'
  params: {
    location: location
    name:'waf-${clusterName}'
    policySettings: {
      fileUploadLimitInMb: 10
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
            ruleSetType: 'OWASP'
            ruleSetVersion: '3.2'
            ruleGroupOverrides: []
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '0.1'
          ruleGroupOverrides: []
        }
      ]
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module agw '../CARML/Microsoft.Network/applicationGateways/deploy.bicep' = {
  name: 'agw'
  params: {
    name: agwName
    location: location
    firewallPolicyId: wafPolicy.outputs.resourceId
    userAssignedIdentities: {
      '${mi_appgateway_frontend.outputs.resourceId}': {}
    }
    sku: 'WAF_v2'
    trustedRootCertificates: [
      {
        name: 'root-cert-wildcard-aks-ingress'
        properties: {
          keyVaultSecretId: '${keyVault.outputs.uri}secrets/${backendCert.outputs.name}'
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'apw-ip-configuration'
        properties: {
          subnet: {
            id: '${targetVnetResourceId}/subnets/snet-applicationgateway'
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'apw-frontend-ip-configuration'
        properties: {
          publicIPAddress: {
            id: '${subscription().id}/resourceGroups/${vNetResourceGroup}/providers/Microsoft.Network/publicIpAddresses/pip-BU0001A0008-00'
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-443'
        properties: {
          port: 443
        }
      }
    ]
    autoscaleMinCapacity: 0
    autoscaleMaxCapacity: 10
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
      exclusions: []
      fileUploadLimitInMb: 10
      disabledRuleGroups: []
    }
    enableHttp2: false
    sslCertificates: [
      {
        name: '${agwName}-ssl-certificate'
        properties: {
          keyVaultSecretId: '${keyVault.outputs.uri}secrets/${frontendCert.outputs.name}'
        }
      }
    ]
    probes: [
      {
        name: 'probe-${aksBackendDomainName}'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {}
        }
      }
    ]
    backendAddressPools: [
      {
        name: aksBackendDomainName
        properties: {
          backendAddresses: [
            {
              fqdn: aksBackendDomainName
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'aks-ingress-backendpool-httpssettings'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/probes/probe-${aksBackendDomainName}'
          }
          trustedRootCertificates: [
            {
              id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/trustedRootCertificates/root-cert-wildcard-aks-ingress'
            }
          ]
        }
      }
    ]
    httpListeners: [
      {
        name: 'listener-https'
        properties: {
          frontendIPConfiguration: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/frontendIPConfigurations/apw-frontend-ip-configuration'
          }
          frontendPort: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/frontendPorts/port-443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/sslCertificates/${agwName}-ssl-certificate'
          }
          hostName: 'bicycle.${domainName}'
          hostNames: []
          requireServerNameIndication: false
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'apw-routing-rules'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/httpListeners/listener-https'
          }
          backendAddressPool: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/backendAddressPools/${aksBackendDomainName}'
          }
          backendHttpSettings: {
            id: '${subscription().id}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/applicationGateways/${agwName}/backendHttpSettingsCollection/aks-ingress-backendpool-httpssettings'
          }
        }
      }
    ]
    zones: pickZones('Microsoft.Network', 'applicationGateways', location, 3)
    diagnosticWorkspaceId: clusterLa.outputs.resourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    frontendCert
    backendCert
    keyVault
    wafPolicy
  ]
}

output aksIngressControllerPodManagedIdentityResourceId string = podmi_ingress_controller.outputs.resourceId
output keyVaultName string = keyVaultName
