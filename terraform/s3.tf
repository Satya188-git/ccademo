module "s3_bucket_athena_results" {
  source  = "app.terraform.io/SempraUtilities/seu-s3/aws"
  version = "11.1.3"

  company_code             = var.company_code
  application_code         = var.application_code
  environment_code         = var.environment_code
  region_code              = var.region_code
  application_use          = "${var.application_use}-athena-results"
  create_bucket            = true
  versioning               = false
  object_ownership         = "BucketOwnerPreferred"
  control_object_ownership = true
  tags                     = var.tags
  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        # kms_master_key_id = module.s3_kms.key_arn
        # sse_algorithm     = "aws:kms"
        sse_algorithm = "AES256"
      }
    }
  }
}