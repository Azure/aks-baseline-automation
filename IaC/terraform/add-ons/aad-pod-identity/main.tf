
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.99.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = ">= 0.9.0"
    }
  }
  required_version = ">= 1.3.1"
}
