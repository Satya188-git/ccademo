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
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-lambda-policy"
  role   = module.lambda_role.name
  policy = templatefile(
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

# Lambda function for NICE API
module "nice_lambda" {

  depends_on = [module.lambda_role] 
  source     = "app.terraform.io/SempraUtilities/seu-lambda/aws"
  version    = "10.0.0"
  
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-nice-data"
  description       = "NICE Lambda with IAC"
  handler           = "hello_world.lambda_handler"
  runtime           = "python3.11"
  memory_size       = "1024"
  timeout           = "300"
  architectures     = ["x86_64"]
  lambda_role       = module.lambda_role.name
  tags              = var.tags
  layers            = [var.pandas_layer_arn]
  publish           = true
  
  s3_existing_package = {
    bucket = var.code_artifact_bucket_name,
    key    = "lambda/packages/nice_lambda/hello_world.zip"
  }
}