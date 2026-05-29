resource "aws_dynamodb_table" "carts" {
  name         = "project-bedrock-carts"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name            = "idx_global_customerId"
    projection_type = "ALL"

    key_schema {
      attribute_name = "customerId"
      key_type       = "HASH"
    }
  }

  tags = {
    Name = "project-bedrock-carts"
  }
}