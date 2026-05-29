resource "kubernetes_secret_v1" "catalog_db" {
  metadata {
    name      = "catalog-db"
    namespace = kubernetes_namespace_v1.retail_app.metadata[0].name
  }

  data = {
    RETAIL_CATALOG_PERSISTENCE_USER     = "catalog"
    RETAIL_CATALOG_PERSISTENCE_PASSWORD = random_password.catalog_db.result
  }

  type = "Opaque"

  depends_on = [
    kubernetes_namespace_v1.retail_app,
    aws_db_instance.catalog_mysql
  ]
}

resource "kubernetes_secret_v1" "orders_db" {
  metadata {
    name      = "orders-db"
    namespace = kubernetes_namespace_v1.retail_app.metadata[0].name
  }

  data = {
    RETAIL_ORDERS_PERSISTENCE_USERNAME = "orders"
    RETAIL_ORDERS_PERSISTENCE_PASSWORD = random_password.orders_db.result
  }

  type = "Opaque"

  depends_on = [
    kubernetes_namespace_v1.retail_app,
    aws_db_instance.orders_postgres
  ]
}
