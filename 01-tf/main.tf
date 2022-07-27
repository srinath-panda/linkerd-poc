

provider "vault" {
  address = "https://vault-testing.infra.works/"
  token   = "s.Xqhynmx0lYT44kXnwAAhksgY"
}

variable "env" {
  type        = string
  default     = "sandbox"
  description = "description"
}

variable "region" {
  type        = string
  default     = "de"
  description = "description"
}



//create a mount
resource "vault_mount" "mesh_kv" {
  path = "svc-mesh-info"
  type = "kv"
}

//upload acndor root certs as secrets
resource "vault_generic_secret" "certs_kv" {
  path = "${vault_mount.mesh_kv.path}/${var.env}-${var.region}/certs/root"
  data_json = jsonencode(
    {
      ca  = local.cert_phase[local.rotation_phase].crt
      crt = local.cert_phase[local.rotation_phase].crt
      key = local.cert_phase[local.rotation_phase].key
    }
  )
}

//create policy
resource "vault_policy" "mesh_kv_policy" {
  name   = "svc-mesh-info-${var.env}-${var.region}"
  policy = file("./cert-man-vault-policy.tpl")
}

provider "kubernetes" {
  config_path = "/Users/srinathrangaramanujam/Documents/Srinath/deliveryhero/src/pd-box/chapters/infra/k8s-configs/config.sandbox-de-3-v121-blue"
}

data "kubernetes_service_account" "vault_sa" {
  metadata {
    name      = "vault"
    namespace = "vault"
  }
}

data "kubernetes_secret" "vault_token_secret" {
  metadata {
    name      = data.kubernetes_service_account.vault_sa.default_secret_name
    namespace = "vault"
  }
}

# //kubernetes auth 
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "sandbox-de-3-v121-blue"
}

//config
resource "vault_kubernetes_auth_backend_config" "k8s_auth_config" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://2C0297ED5AA012C5318A2948D4E7D9B7.gr7.eu-west-1.eks.amazonaws.com"
  kubernetes_ca_cert     = lookup(data.kubernetes_secret.vault_token_secret.data, "ca.crt")
  token_reviewer_jwt     = lookup(data.kubernetes_secret.vault_token_secret.data, "token")
  disable_iss_validation = "true"
}

//k8s-role
resource "vault_kubernetes_auth_backend_role" "k8s_auth_role" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "csi-driver-mesh-role"
  bound_service_account_names      = ["svcmesh-root-cert-sync-service-sa"]
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  token_policies                   = [vault_policy.mesh_kv_policy.name]
}


