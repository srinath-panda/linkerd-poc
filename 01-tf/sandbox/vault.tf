locals {
  bound_service_account_names      = [for v in var.vault_bound_Service_accounts : v.serviceaccounts_name]
  bound_service_account_namespaces = [for v in var.vault_bound_Service_accounts : v.serviceaccounts_namespace]
}

module "vault_sandbox-de" {
  source = "../modules/l5d-k8s-vault"

  k8s_auth_backeds = {
    "sandbox-de-3-v121-blue" = {
      k8s_host                 = data.terraform_remote_state.metacluster.outputs.k8s_clusters["sandbox-de-3-v121-blue"].k8s_host
      k8s_ca_cert              = lookup(data.kubernetes_secret.sandbox-de-3-v121-blue_vault_deletegated_sa_secret.data, "ca.crt")
      delegated_sa_vault_token = lookup(data.kubernetes_secret.sandbox-de-3-v121-blue_vault_deletegated_sa_secret.data, "token")
      roles = {
        "vault-csi-driver-mesh-role" = {
          bound_service_account_names      = local.bound_service_account_names
          bound_service_account_namespaces = local.bound_service_account_namespaces
          token_policies                   = [data.terraform_remote_state.vault.outputs.vault_policies["svc-mesh-info"]]
        }
      }
    }
  }
}
