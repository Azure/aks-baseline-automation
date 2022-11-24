targetScope = 'subscription'

@description('Name of the resource group')
param resourceGroupName string = 'rg-bu0001a0008'
param vNetResourceGroup string = 'rg-enterprise-networking-spokes'

@description('The regional network spoke VNet Resource ID that the cluster will be joined to')
@minLength(79)
param targetVnetResourceId string

@description('Azure AD Group in the identified tenant that will be granted the highly privileged cluster-admin role. If Azure RBAC is used, then this group will get a role assignment to Azure RBAC, else it will be assigned directly to the cluster\'s admin group.')
param clusterAdminAadGroupObjectId string

@description('Azure AD Group in the identified tenant that will be granted the read only privileges in the a0008 namespace that exists in the cluster. This is only used when Azure RBAC is used for Kubernetes RBAC.')
param a0008NamespaceReaderAadGroupObjectId string

@description('Your AKS control plane Cluster API authentication tenant')
param k8sControlPlaneAuthorizationTenantId string = subscription().tenantId


// @description('The certificate data for app gateway TLS termination. It is base64')
// param appGatewayListenerCertificate string = loadTextContent('appgw.crt')

// @description('The Base64 encoded AKS Ingress Controller public certificate (as .crt or .cer) to be stored in Azure Key Vault as secret and referenced by Azure Application Gateway as a trusted root certificate.')
// param aksIngressControllerCertificate string = loadTextContent('traefik-ingress-internal-aks-ingress-tls.crt')

@description('IP ranges authorized to contact the Kubernetes API server. Passing an empty array will result in no IP restrictions. If any are provided, remember to also provide the public IP of the egress Azure Firewall otherwise your nodes will not be able to talk to the API server (e.g. Flux).')
param clusterAuthorizedIPRanges array = []

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
param kubernetesVersion string

@description('Domain name to use for App Gateway and AKS ingress.')
param domainName string

@description('Your cluster will be bootstrapped from this git repo.')
@minLength(9)
param gitOpsBootstrappingRepoHttpsUrl string

@description('You cluster will be bootstrapped from this branch in the identifed git repo.')
@minLength(1)
param gitOpsBootstrappingRepoBranch string

// var networkContributorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
// var monitoringMetricsPublisherRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/3913510d-42f4-4e42-8a64-420c390055eb'
// var acrPullRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
// var managedIdentityOperatorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/f1a07417-d97a-45cb-824c-7a7467783830'
// var virtualMachineContributorRole = '${subscription().id}/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
// var clusterAdminRoleId = 'b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b'
// var clusterReaderRoleId = '7f6c6a51-bcf8-42ba-9220-52d62157d7db'
// var serviceClusterUserRoleId = '4abbcc35-e782-43d8-92c5-2d3f1bd2253f'
var subRgUniqueString = uniqueString('aks', subscription().subscriptionId, resourceGroupName, location)
var nodeResourceGroupName = 'rg-${clusterName}-nodepools'
var clusterName = 'aks-${subRgUniqueString}'
var logAnalyticsWorkspaceName = 'la-${clusterName}'
var defaultAcrName = 'acraks${subRgUniqueString}'
//var vNetResourceGroup = split(targetVnetResourceId, '/')[4]
var vnetName = split(targetVnetResourceId, '/')[8]
var clusterNodesSubnetName = 'snet-clusternodes'
var clusterIngressSubnetName = 'snet-clusteringressservices'
var vnetNodePoolSubnetResourceId = '${targetVnetResourceId}/subnets/${clusterNodesSubnetName}'
// var vnetIngressServicesSubnetResourceId = '${targetVnetResourceId}/subnets/snet-cluster-ingressservices'
var clusterControlPlaneIdentityName = 'mi-${clusterName}-controlplane'
var aksIngressDomainName = 'aks-ingress.${domainName}'
var isUsingAzureRBACasKubernetesRBAC = (subscription().tenantId == k8sControlPlaneAuthorizationTenantId)

resource rg 'Microsoft.Resources/resourceGroups@2019-05-01' existing = {
  name: resourceGroupName
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  scope: resourceGroup(resourceGroupName)
  name: defaultAcrName
}

resource clusterLa 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  scope: resourceGroup(resourceGroupName)
  name: logAnalyticsWorkspaceName
}

module nodeRgRbac '../CARML/Microsoft.Resources/resourceGroups/.bicep/nested_roleAssignments.bicep' = {
  name: '${nodeResourceGroupName}-rbac'
  scope: resourceGroup(nodeResourceGroupName)
  dependsOn: [
    cluster
  ]
  params: {
    resourceId: nodeResourceGroupName
    principalIds: array(cluster.outputs.kubeletidentityObjectId)
    roleDefinitionIdOrName: 'Virtual Machine Contributor'
  }
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

module aksIngressDomain '../CARML/Microsoft.Network/privateDnsZones/deploy.bicep' = {
  name: aksIngressDomainName
  params: {
    name: aksIngressDomainName
    a: [
      {
        name: 'bu0001a0008-00'
        ttl: 3600
        aRecords: [
          {
            ipv4Address: '10.240.4.4'
          }
        ]
      }
    ]
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

module clusterIdentityRbac1 '../CARML/Microsoft.Network/virtualNetworks/subnets/.bicep/nested_roleAssignments.bicep' = {
  name: 'clusterIdentityRbac1'
  params: {
    principalIds: [
      clusterControlPlaneIdentity.outputs.principalId
    ]
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Network Contributor'
    resourceId: '${subscription().id}/resourceGroups/${vNetResourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${clusterNodesSubnetName}'
  }
  scope: resourceGroup(vNetResourceGroup)
  dependsOn: [
    rg
    clusterControlPlaneIdentity
  ]
}

module clusterIdentityRbac2 '../CARML/Microsoft.Network/virtualNetworks/subnets/.bicep/nested_roleAssignments.bicep' = {
  name: 'clusterIdentityRbac2'
  params: {
    principalIds: [
      clusterControlPlaneIdentity.outputs.principalId
    ]
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Network Contributor'
    resourceId: '${subscription().id}/resourceGroups/${vNetResourceGroup}/providers/Microsoft.Network/virtualNetworks/${vnetName}/subnets/${clusterIngressSubnetName}'
  }
  scope: resourceGroup(vNetResourceGroup)
  dependsOn: [
    rg
    clusterControlPlaneIdentity
  ]
}

module AllAzureAdvisorAlert '../CARML/Microsoft.Insights/activityLogAlerts/deploy.bicep' = {
  name: 'AllAzureAdvisorAlert'
  params: {
    name: 'AllAzureAdvisorAlert'
    location: 'global'
    alertDescription: 'All azure advisor alerts'
    enabled: true
    scopes: [
      rg.id
    ]
    conditions: [
      {
        field: 'category'
        equals: 'Recommendation'
      }
      {
        field: 'operationName'
        equals: 'Microsoft.Advisor/recommendations/available/action'
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module cluster '../CARML/Microsoft.ContainerService/managedClusters/deploy.bicep' = {
  name: clusterName
  params: {
    name: clusterName
    location: location
    aksClusterSkuTier: 'Paid'
    aksClusterKubernetesVersion: kubernetesVersion
    aksClusterDnsPrefix: uniqueString(subscription().subscriptionId, rg.name, clusterName)
    primaryAgentPoolProfile: [
      {
        name: 'npsystem'
        count: 3
        vmSize: 'Standard_DS3_v2'
        osDiskSizeGB: 80
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        minCount: 3
        maxCount: 4
        vnetSubnetID: vnetNodePoolSubnetResourceId
        enableAutoScaling: true
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        scaleSetPriority: 'Regular'
        scaleSetEvictionPolicy: 'Delete'
        orchestratorVersion: kubernetesVersion
        enableNodePublicIP: false
        maxPods: 30
        enableAzureRBAC: true
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        upgradeSettings: {
          maxSurge: '33%'
        }
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
    agentPools: [
      {
        name: 'npuser01'
        count: 2
        vmSize: 'Standard_DS3_v2'
        osDiskSizeGB: 120
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        minCount: 2
        maxCount: 5
        vnetSubnetID: vnetNodePoolSubnetResourceId
        enableAutoScaling: true
        enableAzureRbac: true
        type: 'VirtualMachineScaleSets'
        mode: 'User'
        scaleSetPriority: 'Regular'
        scaleSetEvictionPolicy: 'Delete'
        orchestratorVersion: kubernetesVersion
        enableNodePublicIP: false
        maxPods: 30
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        upgradeSettings: {
          maxSurge: '33%'
        }
      }
    ]
    aksServicePrincipalProfile: {
      clientId: 'msi'
    }
    httpApplicationRoutingEnabled: false
    monitoringWorkspaceId: clusterLa.id
    diagnosticLogCategoriesToEnable: [
      'cluster-autoscaler'
      'kube-controller-manager'
      'kube-audit-admin'
      'guard'
    ]
    diagnosticMetricsToEnable: []
    aciConnectorLinuxEnabled: false
    azurePolicyEnabled: true
    azurePolicyVersion: 'v2'
    enableKeyvaultSecretsProvider: true
    enableSecretRotation: 'false'
    nodeResourceGroup: nodeResourceGroupName
    aksClusterNetworkPlugin: 'azure'
    aksClusterNetworkPolicy: 'azure'
    aksClusterOutboundType: 'userDefinedRouting'
    aksClusterLoadBalancerSku: 'standard'
    aksClusterServiceCidr: '172.16.0.0/16'
    aksClusterDnsServiceIP: '172.16.0.10'
    aksClusterDockerBridgeCidr: '172.18.0.1/16'
    aadProfileManaged: true
    aadProfileEnableAzureRBAC: true
    aadProfileAdminGroupObjectIDs: ((!isUsingAzureRBACasKubernetesRBAC) ? array(clusterAdminAadGroupObjectId) : [])
    aadProfileTenantId: k8sControlPlaneAuthorizationTenantId
    autoScalerProfileBalanceSimilarNodeGroups: 'false'
    autoScalerProfileExpander: 'random'
    autoScalerProfileMaxEmptyBulkDelete: '10'
    autoScalerProfileMaxNodeProvisionTime: '15m'
    autoScalerProfileMaxTotalUnreadyPercentage: '45'
    autoScalerProfileNewPodScaleUpDelay: '0s'
    autoScalerProfileOkTotalUnreadyCount: '3'
    autoScalerProfileSkipNodesWithLocalStorage: 'true'
    autoScalerProfileSkipNodesWithSystemPods: 'true'
    autoScalerProfileScanInterval: '10s'
    autoScalerProfileScaleDownDelayAfterAdd: '10m'
    autoScalerProfileScaleDownDelayAfterDelete: '20s'
    autoScalerProfileScaleDownDelayAfterFailure: '3m'
    autoScalerProfileScaleDownUnneededTime: '10m'
    autoScalerProfileScaleDownUnreadyTime: '20m'
    autoScalerProfileUtilizationThreshold: '0.5'
    autoScalerProfileMaxGracefulTerminationSec: '600'
    enablePrivateCluster: false
    authorizedIPRanges: clusterAuthorizedIPRanges
    podIdentityProfileEnable: false
    podIdentityProfileUserAssignedIdentities: []
    podIdentityProfileUserAssignedIdentityExceptions: []
    enableAzureDefender: true
    enableOidcIssuerProfile:true
    // maxAgentPools: 2
    enablePodSecurityPolicy: false
    disableLocalAccounts: true
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
        principalIds: [
          clusterAdminAadGroupObjectId
        ]
      }
      {
        roleDefinitionIdOrName: 'Azure Kubernetes Service Cluster User Role'
        principalIds: [
          clusterAdminAadGroupObjectId
        ]
      }
      {
        roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Reader'
        principalIds: [
          a0008NamespaceReaderAadGroupObjectId
        ]
      }
      {
        roleDefinitionIdOrName: 'Azure Kubernetes Service Cluster User Role'
        principalIds: [
          a0008NamespaceReaderAadGroupObjectId
        ]
      }
    ]
    userAssignedIdentities: {
      '${clusterControlPlaneIdentity.outputs.resourceId}': {}
    }
    diagnosticWorkspaceId: clusterLa.id
    tags: {
      'Business unit': 'BU0001'
      'Application identifier': 'a0008'
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    clusterControlPlaneIdentity
  ]
}

module acrPullRole '../CARML/Microsoft.ContainerRegistry/registries/.bicep/nested_roleAssignments.bicep' = {
  name: 'acrPullRole'
  params: {
    principalIds: [
      cluster.outputs.kubeletidentityObjectId
    ]
    roleDefinitionIdOrName: 'AcrPull'
    resourceId: acr.id
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module managedIdentityOperatorRole '../CARML/Microsoft.ContainerService/managedClusters/.bicep/nested_roleAssignments.bicep' = {
  name: 'managedIdentityOperatorRole'
  params: {
    principalIds: [
      cluster.outputs.kubeletidentityObjectId
    ]
    roleDefinitionIdOrName: 'Managed Identity Operator'
    resourceId: cluster.outputs.resourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}
module managedIdentityOperatorRole2 '../CARML/Microsoft.Resources/resourceGroups/.bicep/nested_roleAssignments.bicep' = {
  name: 'managedIdentityOperatorRole2'
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    cluster
    rg
  ]
  params: {
    resourceId: resourceGroupName
    principalIds: [
      cluster.outputs.kubeletidentityObjectId
    ]
    roleDefinitionIdOrName: 'Managed Identity Operator'
  }
}

module monitoringMetricsPublisherRole '../CARML/Microsoft.ContainerService/managedClusters/.bicep/nested_roleAssignments.bicep' = {
  name: 'monitoringMetricsPublisherRole'
  params: {
    principalIds: [
      cluster.outputs.omsagentIdentityObjectId
    ]
    roleDefinitionIdOrName: 'Monitoring Metrics Publisher'
    resourceId: cluster.outputs.resourceId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module kubernetesConfigurationFlux '../CARML/Microsoft.KubernetesConfiguration/extensions/deploy.bicep' = {
  name: 'flux'
  params: {
    name: 'flux'
    location: location
    extensionType: 'microsoft.flux'
    clusterName: cluster.name
    releaseTrain: 'Stable'
    releaseNamespace: 'flux-system'  
    configurationSettings: {
      'helm-controller.enabled': 'false'
      'source-controller.enabled': 'true'
      'kustomize-controller.enabled': 'true'
      'notification-controller.enabled': 'false'
      'image-automation-controller.enabled': 'false'
      'image-reflector-controller.enabled': 'false'
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    cluster
    acrPullRole
  ]
}

module kubernetesConfigurationFlux2 '../CARML/Microsoft.KubernetesConfiguration/fluxConfigurations/deploy.bicep' = {
  name: 'flux2'
  params: {
    scope: 'cluster'
    name: 'flux2'
    location: location
    namespace: 'flux-system'
    clusterName: cluster.name
    sourceKind: 'GitRepository'
    gitRepository: {
      url: gitOpsBootstrappingRepoHttpsUrl
      timeoutInSeconds: 180
      syncIntervalInSeconds: 300
      repositoryRef: {
        branch: gitOpsBootstrappingRepoBranch
        tag: null
        semver: null
        commit: null
      }
      sshKnownHosts: ''
      httpsUser: null
      httpsCACert: null
      localAuthRef: null
    }
    kustomizations: {
      unified: {
        path: './shared-services'
        dependsOn: []
        timeoutInSeconds: 300
        syncIntervalInSeconds: 300
        retryIntervalInSeconds: null
        prune: true
        force: false
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
    cluster
    acrPullRole
    kubernetesConfigurationFlux
  ]
}

module clusterSystemTopic '../CARML/Microsoft.EventGrid/systemTopics/deploy.bicep' = {
  name: 'clusterSystemTopic'
  params: {
    name: 'clusterSystemTopic'
    location: location
    source: cluster.outputs.resourceId
    topicType: 'Microsoft.ContainerService.ManagedClusters'
    diagnosticWorkspaceId: clusterLa.id
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Node_CPU_utilization_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Node_CPU_utilization_high_for_cluster'
  params: {
    name: 'Node_CPU_utilization_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'Node CPU utilization across the cluster.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'host'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'cpuUsagePercentage'
        metricNamespace: 'Insights.Container/nodes'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: '80'
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Node_working_set_memory_utilization_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Node_working_set_memory_utilization_high_for_cluster'
  params: {
    name: 'Node_working_set_memory_utilization_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'Node working set memory utilization across the cluster.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'host'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'memoryWorkingSetPercentage'
        metricNamespace: 'Insights.Container/nodes'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: '80'
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Jobs_completed_more_than_6_hours_ago_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Jobs_completed_more_than_6_hours_ago_for_cluster'
  params: {
    name: 'Jobs_completed_more_than_6_hours_ago_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors completed jobs (more than 6 hours ago).'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT1M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'completedJobsCount'
        metricNamespace: 'Insights.Container/pods'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 0
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Container_CPU_usage_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Container_CPU_usage_high_for_cluster'
  params: {
    name: 'Container_CPU_usage_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors container CPU utilization.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'cpuExceededPercentage'
        metricNamespace: 'Insights.Container/containers'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 90
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Container_working_set_memory_usage_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Container_working_set_memory_usage_high_for_cluster'
  params: {
    name: 'Container_working_set_memory_usage_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors container working set memory utilization.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'memoryWorkingSetExceededPercentage'
        metricNamespace: 'Insights.Container/containers'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 90
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Pods_in_failed_state_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Pods_in_failed_state_for_cluster'
  params: {
    name: 'Pods_in_failed_state_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'Pod status monitoring.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'phase'
            operator: 'Include'
            values: [
              'Failed'
            ]
          }
        ]
        metricName: 'podCount'
        metricNamespace: 'Insights.Container/pods'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 0
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Disk_usage_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Disk_usage_high_for_cluster'
  params: {
    name: 'Disk_usage_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors disk usage for all nodes and storage devices.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'host'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'device'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'DiskUsedPercentage'
        metricNamespace: 'Insights.Container/nodes'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 80
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Nodes_in_not_ready_status_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Nodes_in_not_ready_status_for_cluster'
  params: {
    name: 'Nodes_in_not_ready_status_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'Node status monitoring.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'status'
            operator: 'Include'
            values: [
              'NotReady'
            ]
          }
        ]
        metricName: 'nodesCount'
        metricNamespace: 'Insights.Container/nodes'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 0
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Containers_getting_OOM_killed_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Containers_getting_OOM_killed_for_cluster'
  params: {
    name: 'Containers_getting_OOM_killed_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors number of containers killed due to out of memory (OOM) error.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT1M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'oomKilledContainerCount'
        metricNamespace: 'Insights.Container/pods'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 0
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Persistent_volume_usage_high_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Persistent_volume_usage_high_for_cluster'
  params: {
    name: 'Persistent_volume_usage_high_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors persistent volume utilization.'
    enabled: false
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'podName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'kubernetesNamespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'pvUsageExceededPercentage'
        metricNamespace: 'Insights.Container/persistentvolumes'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 80
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Pods_not_in_ready_state_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Pods_not_in_ready_state_for_cluster'
  params: {
    name: 'Pods_not_in_ready_state_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors for excessive pods not in the ready state.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT5M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'PodReadyPercentage'
        metricNamespace: 'Insights.Container/pods'
        name: 'Metric1'
        operator: 'LessThan'
        threshold: 80
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module Restarting_container_count_for_cluster '../CARML/Microsoft.Insights/metricAlerts/deploy.bicep' = {
  name: 'Restarting_container_count_for_cluster'
  params: {
    name: 'Restarting_container_count_for_cluster'
    location: 'global'
    alertCriteriaType: 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    alertDescription: 'This alert monitors number of containers restarting across the cluster.'
    enabled: true
    evaluationFrequency: 'PT1M'
    severity: 3
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: 'PT1M'
    scopes: [
      cluster.outputs.resourceId
    ]
    criterias: [
      {
        criterionType: 'StaticThresholdCriterion'
        dimensions: [
          {
            name: 'kubernetes namespace'
            operator: 'Include'
            values: [
              '*'
            ]
          }
          {
            name: 'controllerName'
            operator: 'Include'
            values: [
              '*'
            ]
          }
        ]
        metricName: 'restartingContainerCount'
        metricNamespace: 'Insights.Container/pods'
        name: 'Metric1'
        operator: 'GreaterThan'
        threshold: 0
        timeAggregation: 'Average'
        skipMetricValidation: true
      }
    ]
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module AKSLinuxRestrictive '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
  name: 'AKSLinuxRestrictive'
  params: {
    name: 'AKSLinuxRestrictive'
    location: location
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/42b8ef37-b724-4e24-bbc8-7a7708edfe00'
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroupName
    parameters: {
      excludedNamespaces: {
        value: [
          'kube-system'
          'gatekeeper-system'
          'azure-arc'
          'cluster-baseline-settings'
        ]
      }
      effect: {
        value: 'audit'
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

// module EnforceHttpsIngress '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
//   name: 'EnforceHttpsIngress'
//   params: {
//     name: 'EnforceHttpsIngress'
//     location: location
//     policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
//     subscriptionId: subscription().subscriptionId
//     resourceGroupName: resourceGroupName
//     parameters: {
//       excludedNamespaces: {
//         value: []
//       }
//       effect: {
//         value: 'deny'
//       }
//     }
//   }
//   scope: resourceGroup(resourceGroupName)
//   dependsOn: [
//     rg
//   ]
// }

module EnforceInternalLB '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
  name: 'EnforceInternalLB'
  params: {
    name: 'EnforceInternalLB'
    location: location
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/3fc4dc25-5baf-40d8-9b05-7fe74c1bc64e'
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroupName
    parameters: {
      excludedNamespaces: {
        value: []
      }
      effect: {
        value: 'deny'
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module RootFilesystem '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
  name: 'RootFilesystem'
  params: {
    name: 'RootFilesystem'
    location: location
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/df49d893-a74c-421d-bc95-c663042e5b80'
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroupName
    parameters: {
      excludedNamespaces: {
        value: [
          'kube-system'
          'gatekeeper-system'
          'azure-arc'
        ]
      }
      effect: {
        value: 'audit'
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module EnforceResourceLimits '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
  name: 'EnforceResourceLimits'
  params: {
    name: 'EnforceResourceLimits'
    location: location
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e345eecc-fa47-480f-9e88-67dcc122b164'
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroupName
    parameters: {
      cpuLimit: {
        value: '1000m'
      }
      memoryLimit: {
        value: '512Mi'
      }
      excludedNamespaces: {
        value: [
          'kube-system'
          'gatekeeper-system'
          'azure-arc'
          'cluster-baseline-settings'
          'flux-system'
          'aks-command'
        ]
      }
      effect: {
        value: 'deny'
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

module EnforceImageSource '../CARML/Microsoft.Authorization/policyAssignments/resourceGroup/deploy.bicep' = {
  name: 'EnforceImageSource'
  params: {
    name: 'EnforceImageSource'
    location: location
    policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/febd0533-8e55-448f-b837-bd0e06f16469'
    subscriptionId: subscription().subscriptionId
    resourceGroupName: resourceGroupName
    parameters: {
      allowedContainerImagesRegex: {
        value: '${defaultAcrName}.azurecr.io/.+$|mcr.microsoft.com/.+$|azurearcfork8s.azurecr.io/azurearcflux/images/stable/.+$|docker.io/weaveworks/kured.+$|docker.io/library/.+$'
      }
      excludedNamespaces: {
        value: [
          'kube-system'
          'gatekeeper-system'
          'azure-arc'
        ]
      }
      effect: {
        value: 'deny'
      }
    }
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    rg
  ]
}

output aksClusterName string = clusterName
