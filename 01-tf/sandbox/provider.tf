data "terraform_remote_state" "metacluster" {
  backend = "s3"
  config = {
    bucket  = "pandora-infra-terraform-testing"
    key     = "metacluster/sandbox-de.tfstate"
    region  = "eu-west-1"
    profile = "pd-testing"
  }
}

data "terraform_remote_state" "vault" {
  backend = "s3"
  config = {
    encrypt = "true"
    bucket  = "pandora-vault-staging-terraform"
    key     = "vault-testing/management.tfstate"
    region  = "eu-central-1"
    profile = "pd-vault"
  }
}


provider "vault" {
  address = "https://vault-testing.infra.works/"
  token   = "s.Xqhynmx0lYT44kXnwAAhksgY"
}

provider "aws" {
  profile = "pd-testing"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "pandora-infra-terraform-testing"
    key     = "metacluster/sandbox-de/clusters/terraform.tfstate"
    region  = "eu-west-1"
    profile = "pd-testing"
  }
}

data "aws_eks_cluster_auth" "cluster_auth" {
  for_each = data.terraform_remote_state.metacluster.outputs.k8s_clusters
  name     = each.key
}


provider "kubernetes" {
  host                   = data.terraform_remote_state.metacluster.outputs.k8s_clusters["sandbox-de-3-v121-blue"].k8s_host
  cluster_ca_certificate = base64decode(data.terraform_remote_state.metacluster.outputs.k8s_clusters["sandbox-de-3-v121-blue"].cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster_auth["sandbox-de-3-v121-blue"].token
  alias                  = "sandbox-de-3-v121-blue"
}
