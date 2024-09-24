module "lakeformation_admin" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-lake-formation"
  description       = "IAM role for Lake Formation"
  service_resources = ["glue.amazonaws.com"]
  tags              = var.tags
}

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

module "gluecrawler_role" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-glue-crawler"
  description       = "This is a Glue role to run NICE and Connect crawlers and update respective tables in Athena"
  service_resources = ["glue.amazonaws.com"]
  tags              = var.tags
}

resource "aws_iam_role_policy" "glue_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-glue-crawler"
  role   = module.gluecrawler_role.name
  policy = templatefile("${path.module}/iampolicies/policy-iam-glue-assume-role.tmpl",{})
}

module "eventbridge_role" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"

  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-eventbridge"
  description       = "This is a event bridge scheduler role to schedule the NICE Lambda"
  service_resources = ["scheduler.amazonaws.com"]
  tags              = var.tags
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-eventbridge-policy"
  role   = module.eventbridge_role.name
  policy = templatefile(
    "${path.module}/iampolicies/policy-iam-eventbrdige-assume-role.tmpl",{
      nice_lambda_name = module.nice_lambda.lambda_function_name,
      region = "us-west-2",
      account = var.awsAccount
    })
}