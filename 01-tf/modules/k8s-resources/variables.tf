
variable "annotations" {
  type = map(object({
    apiVersion  = string
    kind        = string
    name        = string
    namespace   = string
    annotations = map(string)
  }))
  default = {}
}


variable "labels" {
  type = map(object({
    apiVersion = string
    kind       = string
    name       = string
    namespace  = string
    labels     = map(string)
  }))
  default = {}
}


variable "namespaces" {
  type = map(object({
    labels      = map(string)
    labels      = map(string)
    annotations = map(string)
  }))
  default = {}
}

variable "serviceaccounts" {
  type = map(object({
    automount_service_account_token = bool
    name                            = string
    namespace                       = string
    labels                          = map(string)
    annotations                     = map(string)
  }))
  default = {}
}

variable "clusterRoleBindings" {
  type = map(object({
    labels      = map(string)
    annotations = map(string)
    roleRef = object({
      api_group = string
      kind      = string
      name = string
    })

    subjects = map(object({
      kind      = string
      name      = string
      namespace = string
    }))
  }))
  default = {}
}
