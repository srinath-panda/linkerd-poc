variable "metacluster_name" {
  type        = string
  description = "Name of the metacluster"
}

variable "certificate_color" {
  type        = string
  default     = "blue"
  description = "current color of the certificate"
}

variable "kv_svc_mesh_pki_path" {
  type        = string
  default     = "svc-mesh-info"
  description = "vault mount path for service mesh secrets/certs"
}

variable "k8s_cluster_name" {
  type        = string
  description = "name of the k8s cluster"
}

variable "delegated_vault_token" {
  type = object({
    create_bound_service_account_namespace = bool
    service_account_namespace              = string
    create_bound_service_account_name      = string
    service_account_name                   = string
  })
  description = "vault service account namespace (https://www.vaultproject.io/docs/auth/kubernetes#use-local-service-account-token-as-the-reviewer-jwt) "
}

variable "whitelisted_vault_token_k8s_namespace" {
  type        = list(string)
  description = "list of service account in namespace name that can call vault"
}

variable "whitelisted_vault_token_sa" {
  type        = list(string)
  description = "list of service account name that can call vault"
}

variable "k8s_host" {
  type        = string
  description = "k8s cluster host"
}
