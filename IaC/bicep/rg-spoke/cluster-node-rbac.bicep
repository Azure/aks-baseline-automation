param nodeResourceGroupName string = resourceGroup().name
param principalId string
param roleDefinitionId string

//can't use carml module as it's targetting mg scope
//we need to make an RG scoped RBAC assignment
//scope "resourceGroup" is not valid for this module. Permitted scopes: "managementGroup"
// module nodeRGRole '../CARML/Microsoft.Authorization/roleAssignments/deploy.bicep' = {
//   name: '${nodeResourceGroupName}-rbac'
//   location: location
//   params: {
//     location: location
//     principalId: cluster.outputs.resourceId
//     roleDefinitionIdOrName: 'Virtual Machine Contributor'
//   }
// }

var roleDefintionResourceId = resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
resource nodeRGRole 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(nodeResourceGroupName, principalId, roleDefintionResourceId)
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefintionResourceId
  }
}
