
variable metacluster_tf_backedn_info {
  type = object({
    bucket  = string
    key     = string
    region  = string
    profile = string
  })
}

data "terraform_remote_state" "metacluster" {
  backend = "s3"
  config  = var.metacluster_tf_backedn_info
}

output metacluster_info {
  value = {
    profile          = var.metacluster_tf_backedn_info.profile
    region           = var.metacluster_tf_backedn_info.region
    metacluster_name = data.terraform_remote_state.metacluster.outputs.metacluster_name
    k8s_clusters = { for name, cluster_ep in data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_endpoint : name =>
      {
        eks_cluster_endpoint   = cluster_ep
        k8s_host               = data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_endpoint[name]
        cluster_ca_certificate = data.terraform_remote_state.metacluster.outputs.metacluster_eks_cluster_certificate_authority_data[name]
      }
    }
  }
}
