@description('Required. The name of the Event Grid Topic')
param name string

@description('Optional. Customer Usage Attribution ID (GUID). This GUID must be previously registered')
param cuaId string = ''

@description('Optional. Use when creating an extension resource at a scope that is different than the deployment scope.')
param scope object

@description('Optional. Flag to note if this extension participates in auto upgrade of minor version, or not.')
param autoUpgradeMinorVersion bool = true

@description('Optional. Configuration settings that are sensitive, as name-value pairs for configuring this extension.')
param configurationProtectedSettings object = {}

@description('Optional. Configuration settings, as name-value pairs for configuring this extension.')
param configurationSettings object = {}

@description('Required. Type of the Extension, of which this resource is an instance of. It must be one of the Extension Types registered with Microsoft.KubernetesConfiguration by the Extension publisher.')
param extensionType string

@description('Optional. ReleaseTrain this extension participates in for auto-upgrade (e.g. Stable, Preview, etc.) - only if autoUpgradeMinorVersion is "true".')
param releaseTrain string = 'Stable'

@description('Optional. Namespace where the extension Release must be placed, for a Cluster scoped extension. If this namespace does not exist, it will be created')
param releaseNamespace string = ''

@description('Optional. Namespace where the extension will be created for an Namespace scoped extension. If this namespace does not exist, it will be created')
param targetNamespace string = ''

@description('Optional. Status from this extension.')
param statuses array = []

@description('Optional. Version of the extension for this extension, if it is "pinned" to a specific version. autoUpgradeMinorVersion must be "false".')
param version string = ''

module pid_cuaId '.bicep/nested_cuaId.bicep' = if (!empty(cuaId)) {
  name: 'pid-${cuaId}'
  params: {}
}

resource extension 'Microsoft.KubernetesConfiguration/extensions@2021-09-01' = {
  name: name
  scope: scope
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    aksAssignedIdentity: {
      type: 'SystemAssigned'
    }
    autoUpgradeMinorVersion: autoUpgradeMinorVersion
    configurationProtectedSettings: !empty(configurationProtectedSettings) ? configurationProtectedSettings : null
    configurationSettings: !empty(configurationSettings) ? configurationSettings : null
    extensionType: extensionType
    releaseTrain: !empty(releaseTrain) ? releaseTrain : null
    scope: {
      cluster: empty(releaseNamespace) ? null : {
        releaseNamespace: releaseNamespace
      }
      namespace: empty(targetNamespace) ? null : {
        targetNamespace: targetNamespace
      }
    }
    statuses: statuses
    version: !empty(version) ? version : null
  }
}

@description('The name of the extension')
output name string = extension.name

@description('The resource ID of the extension')
output resourceId string = extension.id

@description('The name of the resource group the extension was deployed into')
output resourceGroupName string = resourceGroup().name
