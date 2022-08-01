
module "sandbox-de-3-v121-blue" {
  source    = "/Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/dh_projects/mesh/linkerd-poc/01-tf/module"

  metacluster_name          = "sandbox-de"
  k8s_cluster_name          = "sandbox-de-3-v121-blue"
  k8s_host                  = "https://2C0297ED5AA012C5318A2948D4E7D9B7.gr7.eu-west-1.eks.amazonaws.com"
  certificate_color         = "blue"

  delegated_vault_token = {
    create_bound_service_account_namespace = "true"
    service_account_namespace              = "cert-manager"
    create_bound_service_account_name      = "true"
    service_account_name                   = "svcmesh-trust-anchor-cert-sync-service-sa"
  }
  whitelisted_vault_token_k8s_namespace = ["cert-manager"]
  whitelisted_vault_token_sa            = ["svcmesh-trust-anchor-cert-sync-service-sa"]

  
  providers = {
    kubernetes = kubernetes.sandbox-de-3-v121-blue
  }
}


output "test" {
  value = module.sandbox-de-3-v121-blue.test
}
