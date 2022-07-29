resource "kubernetes_namespace" "k8s_namespace_vault_token" {
  for_each = var.delegated_vault_token.create_bound_service_account_namespace ? { 0 = 0 } : {}
  metadata {
    name = var.delegated_vault_token.service_account_namespace
  }
}

resource "kubernetes_service_account" "vault_token_sa" {
  for_each = var.delegated_vault_token.create_bound_service_account_name ? { 0 = 0 } : {}
  metadata {
    name      = var.delegated_vault_token.service_account_name
    namespace = var.delegated_vault_token.service_account_namespace
  }
  depends_on = [kubernetes_namespace.k8s_namespace_vault_token]
}


data "kubernetes_service_account" "vault_token_sa" {
  for_each = var.delegated_vault_token.create_bound_service_account_name ? {} : {0 = 0}
  metadata {
    name      = var.delegated_vault_token.service_account_name
    namespace = var.delegated_vault_token.service_account_namespace
  }
}

locals {
  sa_name_secret = var.delegated_vault_token.create_bound_service_account_name ? kubernetes_service_account.vault_token_sa[0].default_secret_name :  data.kubernetes_service_account.vault_token_sa[0].default_secret_name
}


data "kubernetes_secret" "vault_token_sa_secret" {
  metadata {
    name      = local.sa_name_secret
    namespace = var.delegated_vault_token.service_account_namespace
  }
  depends_on = [kubernetes_service_account.vault_token_sa, data.kubernetes_service_account.vault_token_sa]
}

resource "kubernetes_cluster_role_binding" "vault_auth_delegation" {
  metadata {
    name = "${var.delegated_vault_token.service_account_name}-vault-auth-delegation"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.delegated_vault_token.service_account_name
    namespace = var.delegated_vault_token.service_account_namespace
  }

}
