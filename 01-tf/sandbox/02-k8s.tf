

provider "kubernetes" {
  config_path = "/Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/pd-box/chapters/infra/k8s-configs/config.sandbox-de-3-v121-blue"
}

variable "vault_deletegated_sa" {
  default = "svcmesh-trust-anchor-cert-sync-service-sa"
}


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
    "cert-manager" = {
      annotations = {
        "linkerd.io/inject" = "disabled"
      }
      labels = {
        "config.linkerd.io/admission-webhooks" = "disabled"
      }
    }
  }

  serviceaccounts = {
    "${var.vault_deletegated_sa}" = {
      automount_service_account_token = true
      name                            = var.vault_deletegated_sa
      namespace                       = "cert-manager"
      labels                          = null
      annotations                     = null
    }
  }


  clusterRoleBindings = {
    "${var.vault_deletegated_sa}-vault-auth-delegation" = {
      labels      = {}
      annotations = {}
      roleRef = {
        api_group = "rbac.authorization.k8s.io"
        kind      = "ClusterRole"
        name      = "system:auth-delegator"
      }
      subjects = {
        "${var.vault_deletegated_sa}" = {
          kind      = "ServiceAccount"
          name      = var.vault_deletegated_sa
          namespace = "cert-manager"
        }
      }
    }
  }

}

data "kubernetes_secret" "vault_deletegated_sa_secret" {
  metadata {
    name      = module.sandbox-de-3-v121-blue.serviceaccounts[var.vault_deletegated_sa].secret_name
    namespace = module.sandbox-de-3-v121-blue.serviceaccounts[var.vault_deletegated_sa].namespace
  }
}

output "sandbox-de-3-v121-blue" {
  value = module.sandbox-de-3-v121-blue.serviceaccounts
}
