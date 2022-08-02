//upload acndor root certs as secrets at the path metacluster level
resource "vault_generic_secret" "trust_anchor_certs" {
  path = var.vault_mount_path
  data_json = jsonencode(
    {
      ca  = local.certs_info[var.certificate_color].ca
      crt = local.certs_info[var.certificate_color].crt
      key = local.certs_info[var.certificate_color].key
    }
  )
}

//create policy for the secret to be accessed  
resource "vault_policy" "mesh_kv_policy" {
  name   = var.mesh_kv_policy_name
  policy = templatefile("${path.module}/cert-man-vault-policy.tpl", { policy_path = var.policy_path })
}
