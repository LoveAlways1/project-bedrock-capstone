# Project Bedrock - InnovateMart EKS Deployment

Student ID: `ALT/SOE/025/3180`

AWS Region: `us-east-1`

Repository: `https://github.com/LoveAlways1/project-bedrock-capstone`

## Project Overview

Project Bedrock provisions a production-style AWS EKS environment for InnovateMart’s Retail Store microservices application. The infrastructure is managed with Terraform, the application is deployed with Helm, logs are shipped to CloudWatch, and an event-driven S3-to-Lambda extension is included for product image upload processing.

## Required Resource Names

| Resource              | Name                              |
| --------------------- | --------------------------------- |
| AWS Region            | `us-east-1`                       |
| EKS Cluster           | `project-bedrock-cluster`         |
| VPC Name Tag          | `project-bedrock-vpc`             |
| Kubernetes Namespace  | `retail-app`                      |
| Developer IAM User    | `bedrock-dev-view`                |
| CI/CD Deploy IAM User | `bedrock-cicd-deploy`             |
| S3 Assets Bucket      | `bedrock-assets-alt-soe-025-3180` |
| Lambda Function       | `bedrock-asset-processor`         |
| Required Tag          | `Project=karatu-2025-capstone`    |

## Architecture Summary

The solution includes:

* A new VPC across multiple Availability Zones with public and private subnets.
* An Amazon EKS cluster named `project-bedrock-cluster`.
* Managed node group for application workloads.
* AWS Load Balancer Controller for ALB Ingress.
* Retail Store Sample App deployed into the `retail-app` namespace.
* Amazon RDS MySQL for the catalog service.
* Amazon RDS PostgreSQL for the orders service.
* Amazon DynamoDB for the carts service.
* In-cluster Redis for checkout.
* In-cluster RabbitMQ for orders messaging.
* CloudWatch control plane logging and CloudWatch Observability add-on for container logs.
* Private S3 assets bucket with S3 event notification.
* Lambda function triggered by S3 uploads.
* GitHub Actions CI/CD pipeline for Terraform plan and apply.

## Retail Store Application URL

The Retail Store application is available through the ALB Ingress:

```text
http://k8s-retailap-ui-6039ab69e6-1702191236.us-east-1.elb.amazonaws.com
```

## Terraform Deployment Guide

Terraform root module:

```bash
cd terraform/live
```

Initialize Terraform:

```bash
terraform init
```

Validate Terraform:

```bash
terraform validate
```

Preview infrastructure changes:

```bash
terraform plan
```

Apply infrastructure changes:

```bash
terraform apply
```

## Required Terraform Outputs

The root module outputs:

```text
cluster_endpoint
cluster_name
region
vpc_id
assets_bucket_name
```

Generate the grading output file from the Terraform root module:

```bash
cd terraform/live
terraform output -json > ../../grading.json
```

The generated `grading.json` file is committed at the root of this repository.

## Helm Deployment Guide

The Retail Store application is deployed using the upstream Helm chart committed into this repository.

Helm chart location:

```text
helm/retail-store/src/app/chart
```

Custom project values file:

```text
helm/retail-store/values-project-bedrock.yaml
```

Deploy or upgrade the application:

```bash
helm upgrade --install retail-store helm/retail-store/src/app/chart \
  --namespace retail-app \
  -f helm/retail-store/values-project-bedrock.yaml \
  --wait \
  --timeout 10m
```

Check the release:

```bash
helm list -n retail-app
```

Check pods:

```bash
kubectl get pods -n retail-app
```

Check Ingress:

```bash
kubectl get ingress -n retail-app
```

## Serverless Extension

The S3 assets bucket is:

```text
bedrock-assets-alt-soe-025-3180
```

The Lambda function is:

```text
bedrock-asset-processor
```

When a file is uploaded to the bucket, S3 triggers Lambda. The Lambda function logs the uploaded file name to CloudWatch in this format:

```text
Image received: [filename]
```

Test upload example:

```bash
echo "Project Bedrock test image upload" > /tmp/bedrock-test-image.txt

aws s3 cp /tmp/bedrock-test-image.txt \
  s3://bedrock-assets-alt-soe-025-3180/test-uploads/bedrock-test-image.txt
```

Check Lambda logs:

```bash
MSYS_NO_PATHCONV=1 aws logs filter-log-events \
  --log-group-name "/aws/lambda/bedrock-asset-processor" \
  --filter-pattern "Image received" \
  --query "events[].message" \
  --output text
```

## Developer Access

The required developer/grader IAM user is:

```text
bedrock-dev-view
```

This user has:

* AWS `ReadOnlyAccess`.
* S3 upload permission to `bedrock-assets-alt-soe-025-3180`.
* Kubernetes read-only access in the `retail-app` namespace.
* No permission to delete pods.

Verified command that succeeds:

```bash
kubectl get pods -n retail-app
```

Verified command that fails:

```bash
kubectl delete pod --selector=app.kubernetes.io/name=ui -n retail-app --dry-run=server
```

The access key, secret key, and console login credentials for `bedrock-dev-view` are not stored in this repository. They are provided only in the final Google Document deliverable.

## CI/CD Pipeline

GitHub Actions workflow:

```text
.github/workflows/terraform.yml
```

The workflow is named:

```text
Terraform CI/CD
```

Workflow behavior:

| Event                   | Action                                |
| ----------------------- | ------------------------------------- |
| Pull request to `main`  | Runs `terraform plan`                 |
| Push or merge to `main` | Runs `terraform apply`                |
| Manual trigger          | Available through `workflow_dispatch` |

GitHub repository secrets used by the workflow:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

These credentials belong to the dedicated CI/CD deploy user:

```text
bedrock-cicd-deploy
```

No AWS credentials are hardcoded in the workflow file.

## Observability

EKS control plane logging is enabled for:

```text
api
audit
authenticator
controllerManager
scheduler
```

The Amazon CloudWatch Observability EKS add-on is installed and container logs are shipped to CloudWatch.

Container Insights log groups include:

```text
/aws/containerinsights/project-bedrock-cluster/application
/aws/containerinsights/project-bedrock-cluster/dataplane
/aws/containerinsights/project-bedrock-cluster/host
/aws/containerinsights/project-bedrock-cluster/performance
```

## Security Notes

* RDS databases are deployed in private subnets.
* RDS security groups allow database access only from EKS worker nodes.
* Database credentials are generated with Terraform and stored securely.
* Database passwords are not hardcoded in Helm values.
* The S3 assets bucket is private and has public access blocked.
* The `bedrock-dev-view` user is read-only except for permitted S3 upload access.
* The `bedrock-cicd-deploy` user is used only for CI/CD deployment.

## Cost Reminder

This project creates AWS resources that can incur charges, including EKS, NAT Gateway, RDS, ALB, and related services. Review and clean up resources when the assessment is complete.
