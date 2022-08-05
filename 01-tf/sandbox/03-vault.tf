
provider "vault" {
  address = "https://vault-testing.infra.works/"
  token   = "s.Xqhynmx0lYT44kXnwAAhksgY"
}

variable "cert_color" {
  default = "blue"
}

variable "env" {
  default = "sandbox"
}

variable "cluster_name" {
  default = "sandbox-de-3-v121-blue"
}

locals {
  cert_info = {
    ca  = module.sandbox_linkerd_trust_anchor_certs.certs[var.cert_color].ca
    crt = module.sandbox_linkerd_trust_anchor_certs.certs[var.cert_color].crt
    key = module.sandbox_linkerd_trust_anchor_certs.certs[var.cert_color].key
  }
}

module "vault_sandbox-de-3-v121-blue" {
  source = "../modules/l5d-k8s-vault"

  vault_policies = {
    "svc-mesh-info-${var.env}" = templatefile("./cert-man-vault-policy.tpl", { policy_path = "svc-mesh-info/${var.env}/*" })
  }
  vault_generic_secrets = {
    "svc-mesh-info/${var.env}/certs/trust-anchor" = jsonencode(local.cert_info)
  }

  k8s_auth_backeds = {
    "${var.cluster_name}" = {
      k8s_host                 = "https://2C0297ED5AA012C5318A2948D4E7D9B7.gr7.eu-west-1.eks.amazonaws.com"
      k8s_ca_cert              = lookup(data.kubernetes_secret.vault_deletegated_sa_secret.data, "ca.crt")
      delegated_sa_vault_token = lookup(data.kubernetes_secret.vault_deletegated_sa_secret.data, "token")
      roles = {

        "vault-csi-driver-mesh-role" = {
          bound_service_account_names      = ["svcmesh-trust-anchor-cert-sync-service-sa"]
          bound_service_account_namespaces = ["cert-manager"]

          token_policies = ["svc-mesh-info-${var.env}"]
        }
      }
    }
  }



}
#   k8s_cluster_name = "sandbox-de-3-v121-blue"
#   k8s_host         = "https://2C0297ED5AA012C5318A2948D4E7D9B7.gr7.eu-west-1.eks.amazonaws.com"
#   whitelisted_vault_sa_namespace = ["cert-manager"]
#   whitelisted_vault_token_sa            = ["svcmesh-trust-anchor-cert-sync-service-sa"]



#   mesh_kv_policy_name = "svc-mesh-info-${var.env}"
#   policy_path         = "svc-mesh-info/${var.env}/*"



#   #   policy_names                          = [module.sandbox.svc_mesh_policy_name]

# }

