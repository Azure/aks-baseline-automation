#
# Services supported: subscriptions, storage accounts and resource groups
# Can assign roles to: AD groups, AD object ID, AD applications, Managed identities
#
role_mapping = {

  built_in_role_mapping = {
    keyvaults = {
      secrets = {
        "Contributor" = {
          managed_identities = {
            keys = ["ingress"]
          }
        } // "Contributor"
      }   // logged_in_subscription
    }     // subscriptions
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
  } // built_in_role_mapping
}   // role_mapping

