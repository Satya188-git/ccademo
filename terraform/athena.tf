module "athena" {
  source  = "app.terraform.io/SempraUtilities/seu-athena/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-athena-test"
  tags              = var.tags

#   create_workgroup                   = false
#   publish_cloudwatch_metrics_enabled = true
#   output_location                    = "s3://${module.s3_bucket_athena_results.s3_bucket_id}/output/"
# #   workgroup_encryption_option        = "SSE_KMS"
# #   workgroup_kms_key_arn              = aws_kms_key.athena_kms_key.arn

#   create_athena_database    = true
#   create_athena_named_query = true

#   db_force_destroy       = false
#   athena_db_name         = "iac_test_athena_db"
#   athena_database_bucket = module.s3_bucket_athena_results
#   db_encryption_option   = "SSE_KMS"

# option to create Athena DB and corresponding variables
  create_workgroup = false
  create_athena_database = true
  db_force_destroy       = false
  athena_db_name         = "connect_views_athena_tf"
  athena_database_bucket = module.s3_bucket_athena_results.s3_bucket_id
  db_encryption_option   = "SSE_KMS"
#   db_kms_key_arn         = aws_kms_key.athena_kms_key.arn

  create_athena_named_query = true
  named_query_name          = "iac_test_query"
  named_query_description   = "iac test named query"
  named_query_database      = "connect_views_athena_tf"
  #named_query_query         = "SELECT * FROM \"${module.glue-crawler.glue_database_name}\".\"test\" limit 10;"
  named_query_query = "SELECT contact_id, disconnect_reason, customer_endpoint_address FROM \"dev_connectdatalake\".\"dev_contact_record\";" 


}