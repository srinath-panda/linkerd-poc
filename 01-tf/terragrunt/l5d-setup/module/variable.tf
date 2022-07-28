
data "kubernetes_namespace" "example" {
  metadata {
    name = var.ns
  }
}


variable ns {}

output op {
  value = data.kubernetes_namespace.example
}
