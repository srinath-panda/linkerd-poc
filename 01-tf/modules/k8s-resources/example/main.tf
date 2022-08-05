

provider "kubernetes" {
  config_path = "/Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/pd-box/chapters/infra/k8s-configs/config.sandbox-de-3-v121-blue"
}

module "sample" {
  source = "../"
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
    "svcmesh-trust-anchor-cert-sync-service-sa" = {
      automount_service_account_token = false
      name                            = "svcmesh-trust-anchor-cert-sync-service-sa"
      namespace                       = "cert-manager"
      labels                          = null
      annotations                     = null
    }
  }
}



output "serviceaccounts" {
  value = module.sample.serviceaccounts
}
