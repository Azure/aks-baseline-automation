terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "~> 1.2.20"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.8.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.9.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.19.0"
    }
  }
  required_version = ">= 1.3.0"


  # comment it out for the local backend experience
  backend "azurerm" {}
}


provider "azurerm" {
  partner_id = "451dc593-a3a3-4d41-91e7-3aadf93e1a78"
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
      # TODO with AzureRM 3.0.0+: Uncomment the 2 lines below
      # purge_soft_deleted_certificates_on_destroy = true
      # recover_soft_deleted_certificates          = true
    }
  }
}

provider "azurerm" {
  alias                      = "vhub"
  skip_provider_registration = true
  features {}
  subscription_id = data.azurerm_client_config.default.subscription_id
  tenant_id       = data.azurerm_client_config.default.tenant_id
}

data "azurerm_client_config" "default" {}
