output "serviceaccounts" {
  value = { for k, v in kubernetes_service_account.sa_object : k => {
    name        = v.metadata[0].name
    namespace   = v.metadata[0].namespace
    secret_name = v.default_secret_name
    }
  }
}
