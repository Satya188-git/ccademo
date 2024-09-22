module "lambda_role" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"

  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-lambda"
  description       = "This is a lambda role to write data to S3 and update glue crawlers"
  service_resources = ["lambda.amazonaws.com"]
  tags              = var.tags
  assume_role_policy = templatefile(
    "${path.module}/iampolicies/policy-iam-lambda-assume-role.tmpl",
    {
      region = "us-west-2",
      region_code = var.region_code
      account = var.awsAccount,
      company_code = var.company_code,
      application_code = var.application_code,
      environment_code = var.environment_code,
      application_use = "${var.application_use}-nice-data"
    }
  )
}