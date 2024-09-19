module "s3_bucket" {
  source  = "app.terraform.io/SempraUtilities/seu-s3/aws"
  version = "11.1.3"

  company_code             = var.company_code
  application_code         = var.application_code
  environment_code         = var.environment_code
  region_code              = var.region_code
  application_use          = "${var.application_use}-sai-tf-testing"
  create_bucket            = true
  versioning               = true
  object_ownership         = "BucketOwnerPreferred"
  control_object_ownership = true
  tags                     = var.tags
}
#test