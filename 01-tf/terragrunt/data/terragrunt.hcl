terraform {
  source = ".//"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}

inputs = {
  metacluster_tf_backedn_info = {
    bucket  = "pandora-infra-terraform-testing"
    key     = "metacluster/sandbox-de.tfstate"
    region  = "eu-west-1"
    profile = "pd-testing"
  }
}
