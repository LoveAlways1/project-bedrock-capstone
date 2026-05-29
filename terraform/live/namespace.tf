resource "kubernetes_namespace_v1" "retail_app" {
  metadata {
    name = var.namespace
  }

  depends_on = [
    module.eks
  ]
}
