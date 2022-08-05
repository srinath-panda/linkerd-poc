
# variable "k8s_cluster_name" {
#   type        = string
#   description = "name of the k8s cluster"
# }

# variable "whitelisted_vault_sa_namespace" {
#   type        = list(string)
#   description = "list of service account in namespace name that can call vault"
# }

# variable "whitelisted_vault_token_sa" {
#   type        = list(string)
#   description = "list of service account name that can call vault"
# }

# variable "k8s_host" {
#   type        = string
#   description = "k8s cluster host"
# }

# # variable "delegated_sa_vault_token" {
# #     type        = string
# #   description = "sa token that will call be impersonated"

# # }


# variable cert_info {
#   type = object({
#     ca = string
#     crt = string
#     key = string
#   })
# }

# variable policy_names {
#   default = null
# }


# # variable "vault_mount_path" {
# #   type        = string
# #   description = "vault mount path for service mesh secrets/certs"
# # }

# variable "mesh_kv_policy_name" {
#   type        = string
#   description = "name of vault policy"
# }

# variable "policy_path" {
#   type        = string
#   description = "policy"
# }
