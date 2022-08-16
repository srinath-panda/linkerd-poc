variable "vault_deletegated_service_account" {
  type = object({
    serviceaccounts_name      = string
    serviceaccounts_namespace = string
  })
  default = {
    serviceaccounts_name      = "svcmesh-trust-anchor-cert-sync-service-sa"
    serviceaccounts_namespace = "utils"
  }
}

variable "vault_bound_Service_accounts" {
  type = list(object({
    serviceaccounts_name      = string
    serviceaccounts_namespace = string
  }))
  default = [{
    serviceaccounts_name      = "svcmesh-trust-anchor-cert-sync-service-sa"
    serviceaccounts_namespace = "utils"
  }]
}
