# Lambda function to call NICE API and write data to S3 Bucket
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
  handler           = "nice.lambda_handler"
  runtime           = "python3.11"
  memory_size       = "1024"
  timeout           = "300"
  architectures     = ["x86_64"]
  lambda_role       = module.lambda_role.name
  tags              = var.tags
  layers            = [var.pandas_layer_arn]
  publish           = false
  attach_cloudwatch_logs_policy = false
  create = true
  create_function = true
  create_package = true
  
  s3_existing_package = {
    bucket = var.code_artifact_bucket_name,
    key    = "lambda/packages/nice_lambda/nice.zip"
  }
}