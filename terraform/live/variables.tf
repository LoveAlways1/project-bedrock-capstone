variable "aws_region" {
  type        = string
  description = "AWS region for all project resources."
  default     = "us-east-1"
}

variable "project_tag" {
  type        = string
  description = "Required project tag for all AWS resources."
  default     = "karatu-2025-capstone"
}

variable "cluster_name" {
  type        = string
  description = "Required EKS cluster name."
  default     = "project-bedrock-cluster"
}

variable "vpc_name" {
  type        = string
  description = "Required VPC Name tag."
  default     = "project-bedrock-vpc"
}

variable "namespace" {
  type        = string
  description = "Required Kubernetes namespace for the Retail Store app."
  default     = "retail-app"
}

variable "student_id_normalized" {
  type        = string
  description = "Student ID converted to an AWS-safe lowercase format."
  default     = "alt-soe-025-3180"
}

variable "assets_bucket_name" {
  type        = string
  description = "Required private S3 bucket for product image uploads."
  default     = "bedrock-assets-alt-soe-025-3180"
}

variable "developer_user_name" {
  type        = string
  description = "Required IAM user for developer/grader read-only access."
  default     = "bedrock-dev-view"
}

variable "lambda_function_name" {
  type        = string
  description = "Required Lambda function name for asset processing."
  default     = "bedrock-asset-processor"
}
