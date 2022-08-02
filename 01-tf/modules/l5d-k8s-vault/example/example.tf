

provider "vault" {
  address = "https://vault-testing.infra.works/"
  token   = "s.Xqhynmx0lYT44kXnwAAhksgY"
}

provider "aws" {
  profile = "pd-testing"
  region  = "eu-west-1"
}

data "terraform_remote_state" "metacluster" {
  backend = "s3"
  config = {
    bucket  = "pandora-infra-terraform-testing"
    key     = "metacluster/sandbox-de.tfstate"
    region  = "eu-west-1"
    profile = "pd-testing"
  }
}

locals {
  cluster_name = "sandbox-de-3-v121-blue"
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_endpoint[local.cluster_name]
  cluster_ca_certificate = base64decode(data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_certificate_authority_data[local.cluster_name])
  token                  = data.aws_eks_cluster_auth.cluster.token
}


module "test" {
  source           = "../"
  metacluster_name = data.terraform_remote_state.metacluster.outputs.metacluster_name
  k8s_cluster_name = local.cluster_name
  delegated_vault_token = {
    create_bound_service_account_namespace = true
    service_account_namespace              = "cert-manager"
    create_bound_service_account_name      = true
    service_account_name                   = "svcmesh-trust-anchor-cert-sync-service-sa"
  }
  whitelisted_vault_token_k8s_namespace = ["cert-manager"]
  whitelisted_vault_token_sa            = ["svcmesh-trust-anchor-cert-sync-service-sa"]
  k8s_host                              = data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_endpoint[local.cluster_name]
}

output "test" {
  value = module.test.test
}


resource "local_file" "foo" {
  for_each = module.test.test
  content  = each.value.ca
  filename = "${path.module}/${each.key}"
}
