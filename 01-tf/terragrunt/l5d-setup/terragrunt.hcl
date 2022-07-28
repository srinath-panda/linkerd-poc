dependency "data" {
  config_path = "../data"
}

dependencies {
  paths = ["../data"]
}

locals {
  envInfo = yamldecode(file(find_in_parent_folders("env.yaml")))
  ns = "kube-system"
}


# # Generate a provider for each k8s clusters
generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents = templatefile("../provider.tmpl", {
   aws = local.envInfo.aws
    vault = local.envInfo.vault
    metacluster_info = dependency.data.outputs.metacluster_info
  })
}


generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<EOF
%{ for name, k8s_clusters in dependency.data.outputs.metacluster_info.k8s_clusters ~}
%{ if can(k8s_clusters.k8s_host) }
module "${name}" {
  source    = "./module"
  ns = "${local.ns}"
  providers = {
    kubernetes = kubernetes.${name}
  }
}

output ${name} {
  value = module.${name}.op
}
%{ endif }

%{ endfor ~}
EOF
}


# inputs = {
#   #This module uses the default common vars for this env/region
#   #In the future we will reference states using dependencies
#   profile = "pd-testing"
#   region  = "eu-west-1"
#   metacluster_name = "${dependency.data.outputs.metacluster_info.metacluster_name}"
# }
