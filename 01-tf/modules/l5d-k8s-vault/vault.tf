//kubernetes auth 
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = var.k8s_cluster_name
}

//configure k8s auth (delegated)
resource "vault_kubernetes_auth_backend_config" "k8s_auth_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.k8s_host
  kubernetes_ca_cert     = lookup(data.kubernetes_secret.vault_token_sa_secret.data, "ca.crt")
  token_reviewer_jwt     = lookup(data.kubernetes_secret.vault_token_sa_secret.data, "token")
  disable_iss_validation = "true"
}

//k8s-role
resource "vault_kubernetes_auth_backend_role" "k8s_auth_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "vault-csi-driver-mesh-role"
  bound_service_account_names      = var.whitelisted_vault_token_sa
  bound_service_account_namespaces = var.whitelisted_vault_token_k8s_namespace
  token_ttl                        = 3600
  token_policies                   = var.policy_names
}
