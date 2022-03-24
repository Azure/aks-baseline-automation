targetScope = 'resourceGroup'
param location string = 'eastus'
param date string = utcNow()
var contributorRoleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var kvAdminRoleDefinitionId = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483'


resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'testCertCreationMI'
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid('ContribAccessToKV')
  properties: {
    roleDefinitionId: contributorRoleDefinitionId
    principalId: reference(managedIdentity.id, '2018-11-30').principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}

resource roleAssignment2 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: guid('AdminAccessToKV')
  properties: {
    roleDefinitionId: kvAdminRoleDefinitionId
    principalId: reference(managedIdentity.id, '2018-11-30').principalId
    scope: resourceGroup().id
    principalType: 'ServicePrincipal'
  }
}

resource createAddCertificate 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'createAddCertificate'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    forceUpdateTag: date
    azCliVersion: '2.0.80'
    timeout: 'PT30M'
    scriptContent: '''
    #!/bin/bash
  set -e

  certnamebackend="testappcert"
  certnamefrontend="testappcert-fe"

  echo "creating akv cert $certnamebackend";
  az keyvault certificate create --vault-name "kv-aks-qjzdnsmkiiqo2" -n $certnamebackend -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certnamebackend}/g )";

  echo "creating akv cert $certnamefrontend";
  az keyvault certificate create --vault-name "kv-aks-qjzdnsmkiiqo2" -n $certnamefrontend -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certnamefrontend}/g )";

  sleep 2m
    '''
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
  dependsOn: [
    roleAssignment
    roleAssignment2
  ]
}
