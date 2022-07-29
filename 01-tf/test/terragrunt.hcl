generate "backend" {
  path      = "./backend.tf"
  if_exists = "overwrite"
  contents = <<EOF
terraform {
  backend "s3" {
    encrypt = "true"
    bucket  = "srinath-tfstate"
    key     = "atlantis-test/terraform.tfstate"
    region  = "ap-south-1"
    profile = "pd-testing"
  }
}
EOF
}
