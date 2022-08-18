@description('The name of the Azure Key Vault')
param akvName string

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

@description('The RoleDefinitionId required for the DeploymentScript resource to interact with KeyVault')
param rbacRolesNeededOnKV string = 'a4417e6f-fecd-4de8-b567-7b0420556985' //KeyVault Certificate Officer

@description('Does the Managed Identity already exists, or should be created')
param useExistingManagedIdentity bool = false

@description('Name of the Managed Identity resource')
param managedIdentityName string = 'id-KeyVaultCertificateCreator'

@description('For an existing Managed Identity, the Subscription Id it is located in')
param existingManagedIdentitySubId string = subscription().subscriptionId

@description('For an existing Managed Identity, the Resource Group it is located in')
param existingManagedIdentityResourceGroupName string = resourceGroup().name

@description('The name of the certificate to create')
param certificateNameFE string

@description('The common name of the certificate to create')
param certificateCommonNameFE string = certificateNameFE

@description('The name of the certificate to create')
param certificateNameBE string

@description('The common name of the certificate to create')
param certificateCommonNameBE string = certificateNameBE

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate')
param initialScriptDelay string = '0'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

resource akv 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: akvName
}

@description('A new managed identity that will be created in this Resource Group, this is the default option')
resource newDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = if (!useExistingManagedIdentity) {
  name: managedIdentityName
  location: location
}

@description('An existing managed identity that could exist in another sub/rg')
resource existingDepScriptId 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = if (useExistingManagedIdentity ) {
  name: managedIdentityName
  scope: resourceGroup(existingManagedIdentitySubId, existingManagedIdentityResourceGroupName)
}

resource rbacKv 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (!empty(rbacRolesNeededOnKV)) {
  name: guid(akv.id, rbacRolesNeededOnKV, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
  scope: akv
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', rbacRolesNeededOnKV)
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource rbacKv2 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(akv.id, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
  scope: akv
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'f25e0fa2-a7c8-4377-a976-54943a77a395')
    principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource createImportCert 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'AKV-Cert-${akv.name}-${replace(replace(certificateNameFE,':',''),'/','-')}'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
    }
  }
  kind: 'AzureCLI'
  dependsOn: [
    rbacKv
    rbacKv2
  ]
  properties: {
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.35.0'
    timeout: 'PT10M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'akvName'
        value: akvName
      }
      {
        name: 'certNameFE'
        value: certificateNameFE
      }
      {
        name: 'certCommonNameFE'
        value: certificateCommonNameFE
      }
      {
        name: 'certNameBE'
        value: certificateNameBE
      }
      {
        name: 'certCommonNameBE'
        value: certificateCommonNameBE
      }
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
      {
        name: 'retryMax'
        value: '10'
      }
      {
        name: 'retrySleep'
        value: '5s'
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e

      echo "Waiting on Identity RBAC replication ($initialDelay)"
      sleep $initialDelay

      CURRENT_IP_ADDRESS=$(curl -s -4 https://ifconfig.io)
      az keyvault network-rule add -n $akvName --ip-address $CURRENT_IP_ADDRESS
      sleep $initialDelay

      #Retry loop to catch errors (usually RBAC delays)
      retryLoopCount=0
      until [ $retryLoopCount -ge $retryMax ]
      do
        echo "Creating AKV Cert $certNameFE with CN $certCommonNameFE (attempt $retryLoopCount)..."
        az keyvault certificate create --vault-name $akvName -n $certNameFE -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certCommonNameFE}/g )" \
          && break

        sleep $retrySleep
        retryLoopCount=$((retryLoopCount+1))
    done
      #Retry loop to catch errors (usually RBAC delays)
      retryLoopCount=0
      until [ $retryLoopCount -ge $retryMax ]
      do
        echo "Creating AKV Cert $certNameBE with CN $certCommonNameBE (attempt $retryLoopCount)..."
        az keyvault certificate create --vault-name $akvName -n $certNameBE -p "$(az keyvault certificate get-default-policy | sed -e s/CN=CLIGetDefaultPolicy/CN=${certCommonNameBE}/g )" \
          && break
  
        sleep $retrySleep
        retryLoopCount=$((retryLoopCount+1))
    done
    '''
    cleanupPreference: cleanupPreference
  }
}
