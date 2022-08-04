# User identities role assignments
# resource "azurerm_role_assignment" "user_key_vault_certificates_officer" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = data.azurerm_client_config.default.object_id
# }

# resource "azurerm_role_assignment" "user_key_vault_secrets_officer" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azurerm_client_config.default.object_id
# }

# Managed identities role assignments
# resource "azurerm_role_assignment" "ingress_msi_key_vault_certificates_officer" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = module.caf.managed_identities["ingress"].principal_id
# }

# resource "azurerm_role_assignment" "apgw_keyvault_secrets_msi_key_vault_certificates_officer" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Certificates Officer"
#   principal_id         = module.caf.managed_identities["apgw_keyvault_secrets"].principal_id
# }

# resource "azurerm_role_assignment" "ingress_msi_key_vault_secrets_user" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = module.caf.managed_identities["ingress"].principal_id
# }

# resource "azurerm_role_assignment" "apgw_keyvault_secrets_key_vault_secrets_user" {
#   for_each = module.caf.keyvaults

#   scope                = each.value.id
#   role_definition_name = "Key Vault Secrets User"
#   principal_id         = module.caf.managed_identities["apgw_keyvault_secrets"].principal_id
# }
