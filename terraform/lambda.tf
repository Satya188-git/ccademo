# Lambda function for NICE API

data "archive_file" "nice_lambda_zip"{
  type = "zip"
  source_dir = "${path.module}./src/lambda/hello_world.py"
  output_path = "${path.module}./src/lambda/helloworld_serverless.zip"
}
module "nice_lambda" {

  depends_on = [module.lambda_role,module.s3_bucket_lambda_artifacts] 
  source     = "app.terraform.io/SempraUtilities/seu-lambda/aws"
  version    = "10.0.0"
  
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-nice-lambda"
  description       = "NICE Lambda with IAC"
  handler           = "nice_lambda.lambda_handler"
  runtime           = "python3.11"
  memory_size       = "1024"
  timeout           = "300"
  architectures     = ["x86_64"]

  
  lambda_role       = module.lambda_role.name

  tags              = var.tags
  layers            = [var.pandas_layer_arn]
  
  local_existing_package = "../src/lambda/helloworld_serverless.zip"
}