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

# variable "certificate_color" {
#   type        = string
#   description = "current color of the certificate"
# }

