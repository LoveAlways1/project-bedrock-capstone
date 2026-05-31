# Project Bedrock Architecture Diagram

Student ID: `ALT/SOE/025/3180`

AWS Region: `us-east-1`

## High-Level Architecture

```mermaid
flowchart TB
    user[Users / Browser] --> internet[Internet]
    internet --> alb[Application Load Balancer<br/>AWS Load Balancer Controller]

    subgraph aws[AWS Cloud - us-east-1]
        subgraph vpc[VPC: project-bedrock-vpc]
            subgraph public[Public Subnets - 2 AZs]
                alb
                nat[NAT Gateway]
            end

            subgraph private[Private Subnets - 2 AZs]
                subgraph eks[EKS Cluster: project-bedrock-cluster]
                    ns[Namespace: retail-app]

                    ui[ui service / pod]
                    catalog[catalog service / pod]
                    carts[carts service / pod]
                    checkout[checkout service / pod]
                    orders[orders service / pod]
                    redis[checkout-redis pod]
                    rabbitmq[orders-rabbitmq pod]

                    ns --> ui
                    ns --> catalog
                    ns --> carts
                    ns --> checkout
                    ns --> orders
                    ns --> redis
                    ns --> rabbitmq
                end

                rds_mysql[(RDS MySQL<br/>Catalog DB)]
                rds_pg[(RDS PostgreSQL<br/>Orders DB)]
            end

            alb --> ui
            ui --> catalog
            ui --> carts
            ui --> checkout
            ui --> orders

            catalog --> rds_mysql
            orders --> rds_pg
            checkout --> redis
            orders --> rabbitmq
        end

        dynamodb[(DynamoDB<br/>project-bedrock-carts)]
        secrets[AWS Secrets Manager<br/>DB Credentials]
        cloudwatch[Amazon CloudWatch<br/>Control Plane, Container, Lambda Logs]

        carts --> dynamodb
        catalog --> secrets
        orders --> secrets
        eks --> cloudwatch

        s3[S3 Bucket<br/>bedrock-assets-alt-soe-025-3180]
        lambda[Lambda Function<br/>bedrock-asset-processor]

        s3 -- ObjectCreated Event --> lambda
        lambda --> cloudwatch
    end

    dev[Developer / Grader<br/>bedrock-dev-view] --> s3
    dev --> eks
```

## Architecture Notes

* The application is deployed to the `retail-app` namespace inside the EKS cluster.
* The `ui` service is exposed publicly through an AWS Application Load Balancer.
* The AWS Load Balancer Controller manages the ALB Ingress resource.
* Catalog data uses Amazon RDS MySQL in private subnets.
* Orders data uses Amazon RDS PostgreSQL in private subnets.
* Cart data uses Amazon DynamoDB.
* Redis and RabbitMQ run inside the EKS cluster as allowed by the project instruction.
* Database credentials are stored securely and are not hardcoded in committed Helm values.
* EKS control plane logs and container logs are shipped to CloudWatch.
* S3 uploads to `bedrock-assets-alt-soe-025-3180` trigger the `bedrock-asset-processor` Lambda function.
* Lambda logs the uploaded file name to CloudWatch using the required format: `Image received: [filename]`.
* `bedrock-dev-view` has read-only AWS and Kubernetes access, plus S3 upload permission for the assets bucket.
* `bedrock-cicd-deploy` is used by GitHub Actions to run Terraform CI/CD.
