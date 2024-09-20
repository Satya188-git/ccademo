
# Create the Lambda IAM role

# Create the Lambda
module "hello-lambda" {
  source     = "app.terraform.io/SempraUtilities/seu-lambda/aws"
  version    = "10.0.0"
  depends_on = [module.lambda_role]

  company_code             = var.company_code
  application_code         = var.application_code
  environment_code         = var.environment_code
  region_code              = var.region_code
  application_use          = "${var.application_use}-nice-lambda"
  description      = "Testing Lambda Function with IAC"
  handler          = "hello_world.lambda_handler"
  runtime          = "python3.11"
  memory_size      = "1024"
  timeout          = "120"

  create_package = false

  lambda_role = module.lambda_role.name
  tags        = var.tags

