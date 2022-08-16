//kubernetes auth 
resource "vault_auth_backend" "vault_auth_k8s_backends" {
  for_each = var.k8s_auth_backeds
  type     = "kubernetes"
  path     = each.key
}

# //configure k8s auth (delegated)
resource "vault_kubernetes_auth_backend_config" "k8s_auth_config" {
  for_each               = var.k8s_auth_backeds
  backend                = vault_auth_backend.vault_auth_k8s_backends[each.key].path
  kubernetes_host        = each.value.k8s_host
  kubernetes_ca_cert     = each.value.k8s_ca_cert
  token_reviewer_jwt     = each.value.delegated_sa_vault_token
  disable_iss_validation = "true"
}



locals {
  flatten_auth_backed_roles = flatten([for k, v in var.k8s_auth_backeds : [
    for role_key, role_val in v.roles : {
      backend_key = k
      role_key    = role_key
      role        = role_val
    }
  ]])

  auth_bakend_roles = { for x in local.flatten_auth_backed_roles : "${x.backend_key}__${x.role_key}" => {
    backend_key = x.backend_key
    role_key    = x.role_key
    role        = x.role
    }
  }
}

# //k8s-role
resource "vault_kubernetes_auth_backend_role" "k8s_auth_role" {
  for_each = local.auth_bakend_roles
  backend  = vault_auth_backend.vault_auth_k8s_backends[each.value.backend_key].path

  role_name                        = each.value.role_key
  bound_service_account_names      = each.value.role.bound_service_account_names
  bound_service_account_namespaces = each.value.role.bound_service_account_namespaces
  token_ttl                        = 3600
  token_policies                   = each.value.role.token_policies
}




