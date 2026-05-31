resource "aws_iam_user" "cicd_deploy" {
  name          = "bedrock-cicd-deploy"
  force_destroy = true

  tags = {
    Name = "bedrock-cicd-deploy"
  }
}

resource "aws_iam_user_policy_attachment" "cicd_deploy_admin" {
  user       = aws_iam_user.cicd_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_eks_access_entry" "cicd_deploy" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.cicd_deploy.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "cicd_deploy_admin" {
  cluster_name  = var.cluster_name
  principal_arn = aws_iam_user.cicd_deploy.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [
    aws_eks_access_entry.cicd_deploy
  ]
}
