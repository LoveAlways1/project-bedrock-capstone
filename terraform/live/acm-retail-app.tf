resource "aws_acm_certificate" "retail_app" {
  domain_name       = "store.chnd.space"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "project-bedrock-retail-app-certificate"
  }
}
