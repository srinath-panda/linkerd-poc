variable "k8s_auth_backeds" {
  type = map(object({
    k8s_host                 = string
    k8s_ca_cert              = string
    delegated_sa_vault_token = string
    roles = map(object({
      bound_service_account_names      = list(string)
      bound_service_account_namespaces = list(string)
      token_policies                   = list(string)
    }))
  }))
}

