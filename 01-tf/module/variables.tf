variable metacluster_name {
  type        = string
  description = "Name of the metacluster"
}

variable certificate_color {
  type        = string
  default     = "blue"
  description = "current color of the certificate"
}

variable kv_svc_mesh_pki_path {
  type        = string
  default     = "svc-mesh-info"
  description = "vault mount path for service mesh secrets/certs"
}

variable k8s_cluster_name {
  type        = string
  description = "name of the k8s cluster"

}

variable create_vault_token_k8s_namespace {
  type = bool
  default = true
}

variable vault_token_k8s_namespace {
  type        = string
  description = "vault service account namespace (https://www.vaultproject.io/docs/auth/kubernetes#use-local-service-account-token-as-the-reviewer-jwt) "

}

variable vault_token_sa {
  type        = string
  description = "vault service account name"
}

variable "k8s_host" {
  type        = string
  description = "k8s cluster host"
}
