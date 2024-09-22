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
  additional_policy_statements = [{
			"Effect": "Allow",
			"Action": [
				"glue:GetCrawler",
				"glue:GetTables",
				"glue:StartCrawler",
				"glue:UpdateTable",
				"glue:GetTable"
			],
			"Resource": [
				"arn:aws:glue:us-west-2:${var.awsAccount}:database/*",
				"arn:aws:glue:us-west-2:${var.awsAccount}:crawler/*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"s3:ReplicateObject",
				"s3:PutObject",
				"s3:GetObject",
				"s3:GetObjectAttributes",
				"s3:ListBucket",
				"s3:DeleteObject",
				"s3:GetBucketLocation",
				"s3:ListMultipartUploadParts"
			],
			"Resource": [
				"arn:aws:s3:::${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-s3-${var.application_use}",
				"*"
			]
		},
		{
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
		},
		{
			"Effect": "Allow",
			"Action": [
				"logs:CreateLogGroup",
				"logs:CreateLogStream",
				"logs:PutLogEvents"
			],
			"Resource": [
				"*"
			]
		}]
}