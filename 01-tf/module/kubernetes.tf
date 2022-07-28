resource "kubernetes_namespace" "k8s_namespace_vault_token" {
  for_each = var.create_vault_token_k8s_namespace ? { 0 = 0 } : {}
  metadata {
    name = var.vault_token_k8s_namespace
  }
}

resource "kubernetes_service_account" "vault_token_sa" {
  metadata {
    name      = var.vault_token_sa
    namespace = var.vault_token_k8s_namespace
  }
  depends_on = [kubernetes_namespace.k8s_namespace_vault_token]
}

data "kubernetes_secret" "vault_token_sa_secret" {
  metadata {
    name      = kubernetes_service_account.vault_token_sa.default_secret_name
    namespace = var.vault_token_k8s_namespace
  }
}

resource "kubernetes_cluster_role_binding" "vault_auth_delegation" {
  metadata {
    name = "${var.vault_token_sa}-vault-auth-delegation"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.vault_token_sa
    namespace = var.vault_token_k8s_namespace
  }

}
