

resource "kubernetes_annotations" "resource_annotations" {
  for_each    = var.annotations
  api_version = each.value.apiVersion
  kind        = each.value.kind
  dynamic "metadata" {
    for_each = each.value.namespace == null ? { 0 = 0 } : {}
    content {
      name      = each.value.name
      namespace = each.value.namespace
    }
  }
  dynamic "metadata" {
    for_each = each.value.namespace == null ? {} : { 0 = 0 }
    content {
      name = each.value.name
    }
  }
  annotations = each.value.annotations
}

resource "kubernetes_labels" "resource_labels" {
  for_each    = var.labels
  api_version = each.value.apiVersion
  kind        = each.value.kind
  dynamic "metadata" {
    for_each = each.value.namespace == null ? { 0 = 0 } : {}
    content {
      name      = each.value.name
      namespace = each.value.namespace
    }
  }
  dynamic "metadata" {
    for_each = each.value.namespace == null ? {} : { 0 = 0 }
    content {
      name = each.value.name
    }
  }
  labels     = each.value.labels
  depends_on = [kubernetes_annotations.resource_annotations]
}

#create ns
resource "kubernetes_namespace" "ns_object" {
  for_each = var.namespaces
  metadata {
    annotations = lookup(each.value, "annotations", {})
    labels      = lookup(each.value, "labels", {})
    name        = each.key
  }
}

#create sa
resource "kubernetes_service_account" "sa_object" {
  for_each                        = var.serviceaccounts
  automount_service_account_token = each.value.automount_service_account_token
  metadata {
    name        = each.value.name
    namespace   = each.value.namespace
    annotations = lookup(each.value, "annotations", {})
    labels      = lookup(each.value, "labels", {})
  }
  depends_on = [kubernetes_namespace.ns_object]
}

# create cluster role binding
resource "kubernetes_cluster_role_binding" "cluster_role_binding_object" {
  for_each = var.clusterRoleBindings
  metadata {
    annotations = lookup(each.value, "annotations", {})
    labels      = lookup(each.value, "labels", {})
    name        = each.key
  }
  role_ref {
    api_group = each.value.roleRef.api_group
    kind      = each.value.roleRef.kind
    name      = each.value.roleRef.name
  }

  dynamic "subject" {
    for_each = each.value.subjects
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      namespace = subject.value.namespace
    }
  }
  depends_on = [kubernetes_service_account.sa_object]
}
