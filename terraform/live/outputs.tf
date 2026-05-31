output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = var.cluster_name
}

output "region" {
  description = "AWS region for project resources."
  value       = var.aws_region
}

output "vpc_id" {
  description = "ID of the project VPC."
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "Name of the S3 assets bucket."
  value       = aws_s3_bucket.assets.bucket
}
