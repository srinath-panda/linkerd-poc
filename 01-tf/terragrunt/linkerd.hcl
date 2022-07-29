

locals {
    metacluster_rel_path = "${dirname(path_relative_to_include())}"
    metacluster_name = "${basename(local.metacluster_rel_path)}"
    env_name ="${dirname(local.metacluster_rel_path)}"
    env_dir = "${get_parent_terragrunt_dir()}/${local.env_name}"
    metacluster_dir = "${local.env_dir}/${local.metacluster_name}"
    env_vars = merge(
        yamldecode(file("${local.env_dir}/env.yaml")),
        yamldecode(file("${local.metacluster_dir}/metacluster.yaml")),
        {
          cluster_specific = {
            create_bound_service_account_namespace = true
            service_account_namespace              =  "cert-manager"
            create_bound_service_account_name      = true
            service_account_name  =  "svcmesh-trust-anchor-cert-sync-service-sa"
          }
        }
    )
    remote_backend_info = merge(local.env_vars.remote_backend_info, { key = format("vault_mesh/%v/%v/servicemesh/terraform.tfstate", local.env_name, local.metacluster_name ) })

}

dependency "data" {
  config_path = "${local.metacluster_dir}/data"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "${get_terragrunt_dir()}/backend.tf"
    if_exists = "overwrite"
  }
  config = local.remote_backend_info
}

generate "provider" {
  path      = "${get_terragrunt_dir()}/provider.txt"
  if_exists = "overwrite"
  contents = <<EOF
 "${local.metacluster_rel_path}"
 "${local.metacluster_name}"
 "${local.env_name}"
 "${local.env_dir}"
 "${local.metacluster_dir}"
 "${yamlencode(local.env_vars)}"

 ${get_terragrunt_dir()}
 ${get_parent_terragrunt_dir()}

"${yamlencode(merge(local.env_vars, dependency.data.outputs.metacluster_info))}"
}
EOF
}

# Generate a provider for each k8s clusters
generate "providers" {
  path      = "${get_terragrunt_dir()}/provider.tf"
  if_exists = "overwrite"
  contents = templatefile("${get_parent_terragrunt_dir()}/provider.tmpl", merge(local.env_vars, { metacluster_info =  dependency.data.outputs.metacluster_info}))
}


generate "main" {
  path      = "${get_terragrunt_dir()}/main.tf"
  if_exists = "overwrite"
  contents = templatefile("${get_parent_terragrunt_dir()}/module.tmpl", merge(local.env_vars, { metacluster_info =  dependency.data.outputs.metacluster_info}))
}


# remote_state {
#   backend = "s3"
#   generate = {
#     path      = "${get_terragrunt_dir()}/backend.tf"
#     if_exists = "overwrite"
#   }
#   config = {
#     encrypt = true
#     bucket  = local.env_vars.backend_bucket
#     key     = "${local.env_vars.remote_state_path_prefix}/${local.env_vars.state_id}/terraform.tfstate"
#     region  = local.env_vars.backend_region
#     profile = local.env_vars.aws_account
#   }
# }


# terraform {
#     backend "s3" {
#     encrypt = "true"
#     bucket  = "srinath-tfstate"
#     key     = "atlantis-test/terraform.tfstate"
#     region  = "ap-south-1"
#     profile = "pd-testing"
#   }
# }
