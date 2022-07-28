

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
  #  load_config_file       = false
}

module "test" {
  source                    = "../"
  metacluster_name          = data.terraform_remote_state.metacluster.outputs.metacluster_name
  k8s_cluster_name          = local.cluster_name
  vault_token_k8s_namespace = "cert-manager"
  vault_token_sa            = "svcmesh-trust-anchor-cert-sync-service-sa"
  k8s_host                  = data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_endpoint[local.cluster_name]
  certificate_color         = "blue"
}

