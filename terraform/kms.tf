module "s3_kms" {
  source  = "app.terraform.io/SempraUtilities/seu-kms/aws"
  version = "10.0.3"

  description      = "KMS Key for S3 encryption"
  aws_region       = "us-west-2"
  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = "${var.application_use}-kms"
  tags             = var.tags
}
