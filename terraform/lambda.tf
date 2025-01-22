# Lambda function to send Containment Rate Alerts
module "containment_alerts_lambda" {

  depends_on = [module.lambda_role]
  source     = "app.terraform.io/SempraUtilities/seu-lambda/aws"
  version    = "10.0.0"

  company_code                  = var.company_code
  application_code              = var.application_code
  environment_code              = var.environment_code
  region_code                   = var.region_code
  application_use               = "${var.application_use}-containment-alerts"
  description                   = "Lambda function for Containment Rate Alerts"
  handler                       = "containment_alerts.lambda_handler"
  runtime                       = "python3.11"
  memory_size                   = "1024"
  timeout                       = "300"
  architectures                 = ["x86_64"]
  lambda_role                   = module.lambda_role.name
  tags                          = var.tags
  layers                        = [var.pandas_layer_arn]
  publish                       = true  # Set this to true for versioned Lambda
  attach_cloudwatch_logs_policy = false
  create                        = true
  create_function               = true
  create_package                = false  # Don't package it; use the existing zip in S3
  environment_variables = {
    env = "${var.environment_code}"
  }
  s3_existing_package = {
    bucket = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-s3-artifacts"
    key    = "lambda/packages/containment_alerts/containment_alerts.zip"
  }
}

