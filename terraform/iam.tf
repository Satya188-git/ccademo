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
  additional_policy_statements = [
		{	Sid = "AthenaPermissions",
			"Principal": {
        		"AWS": "lambda.amazonaws.com"
      			},
      		"Action": "sts:AssumeRole",
			"Effect": "Allow",
			"Action": [
				"athena:ListDatabases",
				"athena:ListDataCatalogs",
				"athena:GetTable",
				"athena:GetTableMetadata",
				"athena:GetTables",
				"athena:RunQuery"
			],
			"Resource": [
				"*"
			]
		}
	]
}