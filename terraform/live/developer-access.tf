resource "aws_iam_user" "developer_view" {
  name          = var.developer_user_name
  force_destroy = true

  tags = {
    Name = var.developer_user_name
  }
}

resource "aws_iam_user_policy_attachment" "developer_view_readonly" {
  user       = aws_iam_user.developer_view.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

data "aws_iam_policy_document" "developer_view_assets_upload" {
  statement {
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${aws_s3_bucket.assets.arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "developer_view_assets_upload" {
  name   = "bedrock-assets-upload"
  user   = aws_iam_user.developer_view.name
  policy = data.aws_iam_policy_document.developer_view_assets_upload.json
}

resource "aws_eks_access_entry" "developer_view" {
  cluster_name      = var.cluster_name
  principal_arn     = aws_iam_user.developer_view.arn
  kubernetes_groups = ["bedrock-dev-viewers"]
  type              = "STANDARD"

}

resource "kubernetes_role_binding_v1" "developer_view_retail_app" {
  metadata {
    name      = "bedrock-dev-view"
    namespace = var.namespace
  }

  subject {
    kind      = "Group"
    name      = "bedrock-dev-viewers"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = "view"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [
    aws_eks_access_entry.developer_view
  ]
}
