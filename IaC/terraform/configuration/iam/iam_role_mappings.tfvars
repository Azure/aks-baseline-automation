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
      }
    }
    # AKS Cluster roles provided using ../../locals.tf
    # aks_clusters = {
    #   cluster_re1 = {
    #     "Azure Kubernetes Service RBAC Cluster Admin" = {
    #       # azuread_groups = {
    #       #   keys = ["aks_cluster_re1_admins"]
    #       # }
    #       # logged_in = {
    #       #   keys = ["user"]
    #       # }
    #     }
    #     "Azure Kubernetes Service Cluster User Role" = {
    #       # azuread_groups = {
    #       #   keys = ["aks_cluster_re1_admins, aks_cluster_re1_users"]
    #       # }
    #       # logged_in = {
    #       #   keys = ["user"]
    #       # }
    #     }
    #     "Azure Kubernetes Service RBAC Reader" = {
    #       # azuread_groups = {
    #       #   keys = ["aks_cluster_re1_users"]
    #       # }
    #     }
    #   }
    # }
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

