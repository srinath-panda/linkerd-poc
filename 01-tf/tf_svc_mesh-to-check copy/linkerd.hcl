

locals {
  metacluster_rel_path = "${dirname(path_relative_to_include())}"
  metacluster_name     = "${basename(local.metacluster_rel_path)}"
  env_name             = "${dirname(local.metacluster_rel_path)}"
  env_dir              = "${get_parent_terragrunt_dir()}/${local.env_name}"
  metacluster_dir      = "${local.env_dir}/${local.metacluster_name}"
  env_vars = merge(
    yamldecode(file("${local.env_dir}/env.yaml")),
    yamldecode(file("${local.metacluster_dir}/metacluster.yaml")),
    {
      cluster_specific = {
        create_bound_service_account_namespace = true
        service_account_namespace              = "cert-manager"
        create_bound_service_account_name      = true
        service_account_name                   = "svcmesh-trust-anchor-cert-sync-service-sa"
      }
    }
  )
  remote_backend_info = merge(local.env_vars.remote_backend_info, { key = format("vault_mesh/%v/%v/servicemesh/terraform.tfstate", local.env_name, local.metacluster_name) })
}

dependency "data" {
  config_path                             = "${local.metacluster_dir}/data"
  mock_outputs                            = jsondecode(file("${get_parent_terragrunt_dir()}/templates/mock.json"))
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}


remote_state {
  backend = "s3"
  generate = {
    path      = "${get_terragrunt_dir()}/backend.tf"
    if_exists = "overwrite"
  }
  config = local.remote_backend_info
}

# Generate a provider for each k8s clusters
generate "providers" {
  path      = "${get_terragrunt_dir()}/provider.tf"
  if_exists = "overwrite"
  contents  = templatefile("${get_parent_terragrunt_dir()}/templates/provider.tmpl", merge(local.env_vars, { metacluster_info = dependency.data.outputs.metacluster_info }))
}

generate "main" {
  path      = "${get_terragrunt_dir()}/main.tf"
  if_exists = "overwrite"
  contents  = templatefile("${get_parent_terragrunt_dir()}/templates/module.tmpl", merge(local.env_vars, { metacluster_info = dependency.data.outputs.metacluster_info }))
}

