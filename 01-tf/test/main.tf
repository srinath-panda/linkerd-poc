locals {
  env_backend_info = {
    backend_info = {
      encrypt = true
    }
  }
  metacluster_backend_info = {
    backend_info = {
      encrypt = false
      bucket = "pandora-infra-terraform-testing"
      region = "eu-west-1"
    }
  }
}

output "test" {
  value = merge(local.env_backend_info.backend_info, local.metacluster_backend_info.backend_info)
}
