terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.30.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4.0"
    }
  }
}
