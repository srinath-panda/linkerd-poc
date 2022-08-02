variable "cert_info" {
  type = map(object({
    cert_validity_in_hours = number
    is_ca_certificate      = bool
    common_name            = string
    allowed_uses           = list(string)
    key_algorithm          = string
    key_curve              = string
  }))
}

variable "certificate_color" {
  type        = string
  description = "current color of the certificate"
}

variable "vault_mount_path" {
  type        = string
  description = "vault mount path for service mesh secrets/certs"
}

variable "mesh_kv_policy_name" {
  type        = string
  description = "name of vault policy"
}

variable "policy_path" {
  type        = string
  description = "policy"
}
