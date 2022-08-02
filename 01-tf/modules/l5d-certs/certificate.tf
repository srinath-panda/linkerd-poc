//l5d trust anchor cert private key (root CA key) -- blue
resource "tls_private_key" "private_key" {
  for_each    = var.cert_info
  algorithm   = each.value.key_algorithm
  ecdsa_curve = each.value.key_curve
}

resource "tls_self_signed_cert" "certificate" {
  for_each              = var.cert_info
  private_key_pem       = tls_private_key.private_key[each.key].private_key_pem
  validity_period_hours = each.value.cert_validity_in_hours
  is_ca_certificate     = each.value.is_ca_certificate
  subject {
    common_name = each.value.common_name
  }
  allowed_uses = each.value.allowed_uses
}


locals {

  certs = { for k, v in var.cert_info : k => {
    ca  = tls_self_signed_cert.certificate[k].cert_pem
    crt = tls_self_signed_cert.certificate[k].cert_pem
    key = tls_private_key.private_key[k].private_key_pem
    }
  }

  colors                = [for k, v in var.cert_info : k]                                           //outputs: ["blue", "green"]
  product               = setproduct(local.colors, local.colors)                                    //outputs: [["blue","blue",],["blue","green",],["green","blue",],["green","green",]]
  join_product          = [for k in local.product : join("2", k)]                                   //outputs: ["blue2blue","blue2green","green2blue","green2green",]
  distinct_join_product = [for k in local.join_product : k if split("2", k)[0] != split("2", k)[1]] //outputs: ["blue2green","green2blue",]
  bundle_cert_colors = { for k in local.distinct_join_product : k => {
    crt_color          = split("2", k)[1]
    key_color          = split("2", k)[1]
    primary_ca_color   = split("2", k)[1]
    secondary_ca_color = split("2", k)[0]
    }
  }

  bundles = { for k, v in local.bundle_cert_colors : k => {
    crt = local.certs[v.crt_color].crt
    key = local.certs[v.key_color].key
    ca  = format("%v%v", local.certs[v.primary_ca_color].ca, local.certs[v.secondary_ca_color].ca)
    }
  }

  certs_info = merge(local.certs, local.bundles)
}
