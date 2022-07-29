
locals {
  metacluster_path = "${dirname(path_relative_to_include())}"
  metacluster_name = "${basename(local.metacluster_path)}"
  env_name         = "${dirname(local.metacluster_path)}"
  env_dir          = "${get_parent_terragrunt_dir()}/${local.env_name}"
  metacluster_dir  = "${local.env_dir}/${local.metacluster_name}"
  env_vars = merge(
    yamldecode(file("${local.env_dir}/env.yaml")),
    yamldecode(file("${local.metacluster_dir}/metacluster.yaml")),
  )
}




generate "provider" {
  path      = "${get_terragrunt_dir()}/provider.txt"
  if_exists = "overwrite"
  contents  = <<EOF
 "${local.metacluster_path}"
 "${local.metacluster_name}"
 "${local.env_name}"
 "${local.env_dir}"
 "${local.metacluster_dir}"
 "${yamlencode(local.env_vars)}"

 ${get_terragrunt_dir()}
 ${get_parent_terragrunt_dir()}

}
EOF
}


generate "data" {
  path      = "${get_terragrunt_dir()}/data.tf"
  if_exists = "overwrite"
  contents  = <<EOF
data "terraform_remote_state" "metacluster" {
  backend = "s3"
  config  = {
    bucket  = "${local.env_vars.metacluster_tf_data_backend.bucket}"
    key     = "${local.env_vars.metacluster_tf_data_backend.key}"
    region  = "${local.env_vars.metacluster_tf_data_backend.region}"
    profile = "${local.env_vars.metacluster_tf_data_backend.profile}"
  }
}

output metacluster_info {
  value = {
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
EOF
}
