//create trust anchor root certs 

module "sandbox_linkerd_trust_anchor_certs" {
  source = "../modules/l5d-certs"
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



