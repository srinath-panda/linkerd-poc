
provider "vault" {
  address = "https://vault-testing.infra.works/"
}


module "cert_rotate_test" {
  source = "../"
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


output "certs" {
  value     = module.cert_rotate_test.certs
  sensitive = true
}

# resource "local_file" "ca" {
#   for_each = module.cert_rotate_test.certs
#   content  = each.value.ca
#   filename = "${path.module}/${each.key}-ca"
# }

# resource "local_file" "crt" {
#   for_each = module.cert_rotate_test.certs
#   content  = each.value.crt
#   filename = "${path.module}/${each.key}-crt"
# }

# resource "local_file" "key" {
#   for_each = module.cert_rotate_test.certs
#   content  = each.value.key
#   filename = "${path.module}/${each.key}-key"
# }
