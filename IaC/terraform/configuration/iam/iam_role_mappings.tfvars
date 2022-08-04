#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {

  built_in_role_mapping = {
    keyvaults = {
      secrets = {
        "Key Vault Reader" = {
          managed_identities = {
            keys = ["ingress", "apgw_keyvault_secrets"]
          }
        }
        "Key Vault Secrets User" = {
          managed_identities = {
            keys = ["ingress", "apgw_keyvault_secrets"]
          }
        }
        "Key Vault Certificates Officer" = {
          logged_in = {
            keys = ["user"]
          }
          managed_identities = {
            keys = ["ingress", "apgw_keyvault_secrets"]
          }
        }
        "Key Vault Secrets Officer" = {
          logged_in = {
            keys = ["user"]
          }
        }
      }
    }
    aks_clusters = {
      cluster_re1 = {
        "Azure Kubernetes Service RBAC Cluster Admin" = {
          # azuread_groups = {
          #   keys = ["aks_admins"]
          # }
          logged_in = {
            keys = ["user"]
          }
        }
      }
    }
    azure_container_registries = {
      acr1 = {
        "AcrPull" = {
          aks_clusters = {
            keys = ["cluster_re1"]
          }
        }
      }
    }
    resource_groups = {
      aks_re1 = {
        "Monitoring Metrics Publisher" = {
          aks_clusters = {
            keys = ["cluster_re1"]
          }
        }
      }
    }
  } // built_in_role_mapping
}   // role_mapping

