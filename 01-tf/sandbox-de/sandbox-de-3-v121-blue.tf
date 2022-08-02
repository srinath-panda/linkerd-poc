



variable "cert_color" {
  type        = string
  description = "linkerd trust anchor certificate color to be used by this k8s cluster"
  default     = "blue"
}

module "sandbox-de-3-v121-blue" {
  source = "../modules/l5d-k8s-vault"

  k8s_cluster_name = "sandbox-de-3-v121-blue"
  k8s_host         = "https://2C0297ED5AA012C5318A2948D4E7D9B7.gr7.eu-west-1.eks.amazonaws.com"

  delegated_vault_token = {
    create_bound_service_account_namespace = "true"
    service_account_namespace              = "cert-manager"
    create_bound_service_account_name      = "true"
    service_account_name                   = "svcmesh-trust-anchor-cert-sync-service-sa"
  }
  whitelisted_vault_token_k8s_namespace = ["cert-manager"]
  whitelisted_vault_token_sa            = ["svcmesh-trust-anchor-cert-sync-service-sa"]
  policy_names                          = [module.sandbox.svc_mesh_policy_name]

  cert_info = {
    ca  = module.sandbox.certs[var.cert_color].ca
    crt = module.sandbox.certs[var.cert_color].crt
    key = module.sandbox.certs[var.cert_color].key
  }

  providers = {
    kubernetes = kubernetes.sandbox-de-3-v121-blue
  }
}

