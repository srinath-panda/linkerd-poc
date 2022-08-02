
output "certs" {
  value = local.certs_info
}


output "svc_mesh_policy_name" {
  value = vault_policy.mesh_kv_policy.name
}
