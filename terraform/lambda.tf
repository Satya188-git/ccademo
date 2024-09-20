
# Create the Lambda IAM role

# Create the Lambda
module "nice_lambda" {
  source     = "app.terraform.io/SempraUtilities/seu-lambda/aws"
  version    = "10.0.0"
  depends_on = [module.lambda_role,module.s3_bucket_lambda_artifacts] 

  company_code             = var.company_code
  application_code         = var.application_code
  environment_code         = var.environment_code
  region_code              = var.region_code
  application_use          = "${var.application_use}-nice-lambda"
  description      = "Testing Lambda Function with IAC"
  handler          = "nice_lambda.lambda_handler"
  runtime          = "python3.11"
  memory_size      = "1024"
  timeout          = "120"
  publish = true
  architectures = ["x86_64"] 
  create_package = false

  lambda_role = module.lambda_role.name
  tags        = var.tags

  s3_existing_package = {
    bucket = module.s3_bucket_lambda_artifacts.name
    key    = var.serverless_application_zip
  }
}

