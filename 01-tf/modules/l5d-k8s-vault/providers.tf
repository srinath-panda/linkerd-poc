terraform {
  required_version = ">=1.1"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.0"
    }
  }
}
