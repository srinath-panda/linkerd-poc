module "sandbox-de-3-v121-blue" {
  source = "../modules/k8s-resources"
  labels = {
    kube-system = {
      apiVersion = "v1"
      kind       = "Namespace"
      name       = "kube-system"
      namespace  = null
      labels = {
        "config.linkerd.io/admission-webhooks" = "disabled"
      }
    }
  }

  namespaces = {
    "linkerd" = {
      annotations = {
        "linkerd.io/inject" = "disabled"
      }
      labels = {
        "linkerd.io/is-control-plane"          = "true"
        "config.linkerd.io/admission-webhooks" = "disabled"
        "linkerd.io/control-plane-ns"          = "linkerd"
      }
    }
  }

  serviceaccounts = {
    "${var.vault_deletegated_service_account.serviceaccounts_name}" = {
      automount_service_account_token = true
      name                            = var.vault_deletegated_service_account.serviceaccounts_name
      namespace                       = var.vault_deletegated_service_account.serviceaccounts_namespace
      labels                          = null
      annotations                     = null
    }
  }

  clusterRoleBindings = {
    "$k8s-sa-vault-auth-delegation" = {
      labels      = {}
      annotations = {}
      roleRef = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "system:auth-delegator"
      }
      subjects = { for v in var.vault_bound_Service_accounts : "${v.serviceaccounts_name}__${v.serviceaccounts_namespace}" => {
        kind      = "ServiceAccount"
        name      = v.serviceaccounts_name
        namespace = v.serviceaccounts_namespace
        }
      }
    }
  }

  providers = {
    kubernetes = kubernetes.sandbox-de-3-v121-blue
  }
}

data "kubernetes_secret" "sandbox-de-3-v121-blue_vault_deletegated_sa_secret" {
  provider = kubernetes.sandbox-de-3-v121-blue
  metadata {
    name      = module.sandbox-de-3-v121-blue.serviceaccounts[var.vault_deletegated_service_account.serviceaccounts_name].secret_name
    namespace = module.sandbox-de-3-v121-blue.serviceaccounts[var.vault_deletegated_service_account.serviceaccounts_name].namespace
  }
}
