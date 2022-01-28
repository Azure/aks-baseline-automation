param resourceId_Microsoft_ContainerService_managedClusters_variables_clusterName object
param variables_virtualMachineContributorRole ? /* TODO: fill in correct type */

resource id 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(resourceGroup().id)
  properties: {
    roleDefinitionId: variables_virtualMachineContributorRole
    principalId: resourceId_Microsoft_ContainerService_managedClusters_variables_clusterName.identityProfile.kubeletidentity.objectId
    principalType: 'ServicePrincipal'
  }
}