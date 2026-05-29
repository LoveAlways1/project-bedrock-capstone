resource "aws_secretsmanager_secret" "catalog_db" {
  name = "project-bedrock/catalog-db"

  tags = {
    Name = "project-bedrock-catalog-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "catalog_db" {
  secret_id = aws_secretsmanager_secret.catalog_db.id

  secret_string = jsonencode({
    username = "catalog"
    password = random_password.catalog_db.result
    database = "catalog"
    host     = aws_db_instance.catalog_mysql.address
    port     = 3306
  })
}

resource "aws_secretsmanager_secret" "orders_db" {
  name = "project-bedrock/orders-db"

  tags = {
    Name = "project-bedrock-orders-db-secret"
  }
}

resource "aws_secretsmanager_secret_version" "orders_db" {
  secret_id = aws_secretsmanager_secret.orders_db.id

  secret_string = jsonencode({
    username = "orders"
    password = random_password.orders_db.result
    database = "orders"
    host     = aws_db_instance.orders_postgres.address
    port     = 5432
  })
}
