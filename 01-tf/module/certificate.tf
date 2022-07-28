//l5d trust anchor cert private key (root CA key) -- blue
resource "tls_private_key" "trust_anchor_key_blue" {
  algorithm   = "ECDSA" //only this algo is supported by l5d 
  ecdsa_curve = "P256"  //minimum curve l5d supports 
}

//l5d trust anchor cert (root CA cert) -- blue
resource "tls_self_signed_cert" "trust_anchor_cert_blue" {
  private_key_pem       = tls_private_key.trust_anchor_key_blue.private_key_pem
  validity_period_hours = 8760
  is_ca_certificate     = true
  subject {
    common_name = "root.linkerd.cluster.local"
  }
  allowed_uses = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
}



//l5d trust anchor cert private key (root CA key) -- green
resource "tls_private_key" "trust_anchor_key_green" {
  algorithm   = "ECDSA" //only this algo is supported by l5d 
  ecdsa_curve = "P256"  //minimum curve l5d supports 
}

//l5d trust anchor cert (root CA cert) -- green
resource "tls_self_signed_cert" "trust_anchor_cert_green" {
  private_key_pem       = tls_private_key.trust_anchor_key_green.private_key_pem
  validity_period_hours = 8760
  is_ca_certificate     = true
  subject {
    common_name = "root.linkerd.cluster.local"
  }
  allowed_uses = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
}


//cert rotation (in progress)
locals {
  trust_anchor_certs = {
    "blue" = {
      crt = tls_self_signed_cert.trust_anchor_cert_blue.cert_pem
      key = tls_private_key.trust_anchor_key_blue.private_key_pem
    }
    "green" = {
      crt = tls_self_signed_cert.trust_anchor_cert_green.cert_pem
      key = tls_private_key.trust_anchor_key_green.private_key_pem
    }
  }
}



