
//create self signed certs
resource "tls_private_key" "private_key" {
  algorithm   = "ECDSA" //only this algo is supported by l5d 
  ecdsa_curve = "P256"  //minimum curve l5d supports 
}

resource "tls_self_signed_cert" "self_signed_cert" {
  private_key_pem       = tls_private_key.private_key.private_key_pem
  validity_period_hours = 8760
  is_ca_certificate     = true
  subject {
    common_name = "root.linkerd.cluster.local"
  }
  allowed_uses = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
}

resource "tls_private_key" "private_key_green" {
  ecdsa_curve = "P256"
  algorithm   = "ECDSA"
}

resource "tls_self_signed_cert" "self_signed_cert_green" {
  private_key_pem       = tls_private_key.private_key_green.private_key_pem
  validity_period_hours = 8760
  is_ca_certificate     = true
  subject {
    common_name = "root.linkerd.cluster.local"
  }
  allowed_uses = ["cert_signing", "crl_signing", "client_auth", "server_auth"]
}


/*
A. blue is active (no roataion in progress)
B. renew the inactive certificate CA (green)
  1. terraform taint green 
  2. tf apply - green gets replaced with new cert and there is no impact
C. start rotation 
  1. set var.rotation_phase=1
     make blue, green active, green becomes 
      ca = bundle (blue,green)
      crt = green 
      key = green 
3. deprecate blue totally 
*/


/*
Allowed rotation phasec

1. blue /green
2. blue2green 
3. green2blue
*/

locals {
  rotation_phase = "blue"
}

locals {
  final_rotation_phases = {
    "blue" = {
      crt = tls_self_signed_cert.self_signed_cert.cert_pem
      key = tls_private_key.private_key.private_key_pem
    }
    "green" = {
      crt = tls_self_signed_cert.self_signed_cert_green.cert_pem
      key = tls_private_key.private_key_green.private_key_pem
    }
  }

  in_progress_phases = {
    "blue2green" = merge(local.final_rotation_phases["green"], { ca = local.final_rotation_phases["blue"].crt })
    "green2blue" = merge(local.final_rotation_phases["blue"], { ca = local.final_rotation_phases["green"].crt })
  }

  cert_phase = merge(local.in_progress_phases, local.final_rotation_phases)

}
