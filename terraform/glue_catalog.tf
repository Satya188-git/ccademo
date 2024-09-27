# Module to create connect data resource link in Lake formation
module "glue_data_catalog_connect_datalake" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}"
  tags = var.tags
  # glue catalog database
  glue_database_name = "connect_datalake_link"
  glue_catalog_map = {}

  add_linked_database = true
  target_catalog_id = var.producer_catalog_id
  target_database_name = var.source_database_name
  
}

# Module to create data base for views in Lake formation
module "glue_database_connect_datalake_views" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-crawler/aws"
  version = "10.1.0"

  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}"
  tags = var.tags

  iam_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_role_name = data.aws_iam_session_context.current.issuer_name

  glue_database_map = {
    database1 = {
      // job specific name here gets appended to standardized name
      name = "connect_datalake_views"
      optional_arguments = {
        description = "This database stored all the views created on top of the Connect Data Lake Link used"
      }
    }
  }
}
