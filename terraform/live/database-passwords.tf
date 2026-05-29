resource "random_password" "catalog_db" {
  length  = 24
  special = false
}

resource "random_password" "orders_db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
