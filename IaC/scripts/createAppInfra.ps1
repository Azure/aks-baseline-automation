## ------------------------------------------------------------------------
## Input Parameters
## 
## ------------------------------------------------------------------------

param(
  [Parameter()]
  [String]$ResourceGroupName,
  [String]$AKSName,
  [String]$ACRName,
  [String]$Location
) 

## ------------------------------------------------------------------------
## Resource Group 
## Check if resource groups exists with name provided, if not create it
## ------------------------------------------------------------------------

Write-Output "*** Check if Resource Group $ACRName exists"
$checkRg = az group exists --name $ACRName | ConvertFrom-Json
if (!$checkRg) {
  Write-Warning "*** WARN! Resource Group $ACRName does not exist. Creating..."
  az group create --name $ACRName --location $location

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
  az acr create -n $ACRName -g $ACRRGNAME --location $Location --sku Standard --admin-enabled

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

Write-Output "*** Check if ACR $ACRName exists"
$checkAKS = az aks show -n $AKSName -g $ResourceGroupName | ConvertFrom-Json
if (!$checkAKS) {
  Write-Warning "*** WARN! ACR $ACRName does not exist. Creating..."
  az aks create -n $AKSName -g $ResourceGroupName --location $Location --attach-acr $ACRName

  if ($LastExitCode -ne 0) {
    throw "*** Error - could not create cluster"
  }
}
else
{
  Write-Output "*** Ok"
}

