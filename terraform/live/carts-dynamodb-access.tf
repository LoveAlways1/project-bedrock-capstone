data "aws_iam_policy_document" "carts_dynamodb" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.carts.arn,
      "${aws_dynamodb_table.carts.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "carts_dynamodb" {
  name        = "project-bedrock-carts-dynamodb"
  description = "Allow carts service to access the project Bedrock DynamoDB carts table."
  policy      = data.aws_iam_policy_document.carts_dynamodb.json

  tags = {
    Name = "project-bedrock-carts-dynamodb"
  }
}

data "aws_iam_policy_document" "carts_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"
      values   = ["system:serviceaccount:${var.namespace}:carts"]
    }
  }
}

resource "aws_iam_role" "carts_dynamodb" {
  name               = "project-bedrock-carts-dynamodb"
  assume_role_policy = data.aws_iam_policy_document.carts_assume_role.json

  tags = {
    Name = "project-bedrock-carts-dynamodb"
  }
}

resource "aws_iam_role_policy_attachment" "carts_dynamodb" {
  role       = aws_iam_role.carts_dynamodb.name
  policy_arn = aws_iam_policy.carts_dynamodb.arn
}

resource "kubernetes_service_account_v1" "carts" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace_v1.retail_app.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.carts_dynamodb.arn
    }
  }

  depends_on = [
    kubernetes_namespace_v1.retail_app,
    aws_iam_role_policy_attachment.carts_dynamodb
  ]
}
