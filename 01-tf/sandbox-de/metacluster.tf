
variable "kv_svc_mesh_pki_path" {
  type        = string
  default     = "svc-mesh-info"
  description = "vault mount path for service mesh secrets/certs"
}

variable "metacluster_name" {
  type        = string
  default     = "sandbox-de"
  description = "Name of the metacluster"
}

module "sandbox" {
  source              = "../modules/l5d-certs"
  certificate_color   = "blue"
  vault_mount_path    = "${var.kv_svc_mesh_pki_path}/${var.metacluster_name}/certs/trust-anchor"
  mesh_kv_policy_name = "svc-mesh-info-${var.metacluster_name}"
  policy_path         = "svc-mesh-info/${var.metacluster_name}/*"
  cert_info = {
    "blue" = {
      cert_validity_in_hours = 8760
      is_ca_certificate      = true
      common_name            = "root.linkerd.cluster.local"
      allowed_uses           = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
      key_algorithm          = "ECDSA" //only this algo is supported by l5d 
      key_curve              = "P256"  //minimum curve l5d supports
    }
    "green" = {
      cert_validity_in_hours = 8760
      is_ca_certificate      = true
      common_name            = "root.linkerd.cluster.local"
      allowed_uses           = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
      key_algorithm          = "ECDSA" //only this algo is supported by l5d 
      key_curve              = "P256"  //minimum curve l5d supports
    }
  }
}
