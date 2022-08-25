## ------------------------------------------------------------------------
## Input Parameters
## 
## ------------------------------------------------------------------------

param(
  [Parameter()]
  [String]$ResourceGroupName,
  [String]$DefaultPrefix,
  [String]$AKSName,
  [String]$ACRName,
  [String]$Location
) 

## ------------------------------------------------------------------------
## Resource Group 
## Check if resource groups exists with name provided, if not create it
## ------------------------------------------------------------------------

Write-Output "*** Check if Resource Group $ResourceGroupName exists"
$checkRg = az group exists --name $ResourceGroupName | ConvertFrom-Json
if (!$checkRg) {
  Write-Warning "*** WARN! Resource Group $ResourceGroupName does not exist. Creating..."
  $name = "$DefaultPrefix-rg"
  $ResourceGroupName = $name
  az group create --name $name --location $Location

  if ($LastExitCode -ne 0) {
    throw "*** Error - could not create resource group"
  }
}
else
{
  Write-Output "*** Ok"
}

## ------------------------------------------------------------------------
## Azure Container Registry (ACR)
## Check if ACR exists with name provided, if not create it
## ------------------------------------------------------------------------

Write-Output "*** Check if ACR $ACRName exists"
$checkAcr = az acr show --name $ACRName | ConvertFrom-Json
if (!$checkAcr) {
  Write-Warning "*** WARN! ACR $ACRName does not exist. Creating..."
  $ACRName = $DefaultPrefix
  az acr create -n $DefaultPrefix -g $ResourceGroupName --location $Location --sku Standard --admin-enabled

  if ($LastExitCode -ne 0) {
    throw "*** Error - could not create ACR"
  }
}
else
{
  Write-Output "*** Ok"
}

## ------------------------------------------------------------------------
## AKS
## Check if cluster exists with name provided, if not create it
## ------------------------------------------------------------------------

Write-Output "*** Check if cluster $AKSName exists"
$checkAKS = az aks show -n $AKSName -g $ResourceGroupName | ConvertFrom-Json
if (!$checkAKS) {
  Write-Warning "*** WARN! AKS $AKSName does not exist. Creating..."

  $name = "$($DefaultPrefix)aks"
  az aks create -g $ResourceGroupName -n $name --enable-managed-identity --node-count 1 --enable-addons monitoring --enable-msi-auth-for-monitoring  --generate-ssh-keys --attach-acr $ACRName

  if ($LastExitCode -ne 0) {
    throw "*** Error - could not create cluster"
  }
}
else
{
  Write-Output "*** Ok"
}

