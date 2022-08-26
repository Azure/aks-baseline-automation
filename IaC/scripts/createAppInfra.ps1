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

Write-Output "*** Check if Resource Group $ResourceGroupName exists"
$checkRg = az group exists --name $ResourceGroupName | ConvertFrom-Json
if (!$checkRg) {
  Write-Warning "*** WARN! Resource Group $ResourceGroupName does not exist. Creating..."
  az group create --name $ResourceGroupName --location $Location

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
  az acr create -n $ACRName -g $ResourceGroupName --location $Location --sku Standard --admin-enabled

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
## Update cluster with ACR
## ------------------------------------------------------------------------

az aks update -n $AKSName -g $ResourceGroupName --attach-acr $ACRName


