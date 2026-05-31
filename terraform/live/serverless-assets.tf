data "archive_file" "asset_processor" {
  type        = "zip"
  source_file = "${path.module}/../../lambda/asset_processor.py"
  output_path = "${path.module}/../../lambda/asset_processor.zip"
}

resource "aws_s3_bucket" "assets" {
  bucket = var.assets_bucket_name

  tags = {
    Name = var.assets_bucket_name
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_role" "asset_processor_lambda" {
  name = "project-bedrock-asset-processor-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "project-bedrock-asset-processor-lambda-role"
  }
}

resource "aws_iam_role_policy_attachment" "asset_processor_basic_execution" {
  role       = aws_iam_role.asset_processor_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "asset_processor" {
  function_name = var.lambda_function_name

  filename         = data.archive_file.asset_processor.output_path
  source_code_hash = data.archive_file.asset_processor.output_base64sha256

  role    = aws_iam_role.asset_processor_lambda.arn
  handler = "asset_processor.lambda_handler"
  runtime = "python3.12"
  timeout = 30

  depends_on = [
    aws_iam_role_policy_attachment.asset_processor_basic_execution
  ]

  tags = {
    Name = var.lambda_function_name
  }
}

resource "aws_lambda_permission" "allow_s3_assets" {
  statement_id  = "AllowExecutionFromAssetsBucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.asset_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "assets" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.asset_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3_assets
  ]
}
