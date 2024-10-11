# Module to create connect data resource link in Lake formation
# Create a resource link from connect datalake
module "glue_data_catalog_connect_datalake" {
  source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version               = "10.0.4"
  company_code          = var.company_code
  application_code      = var.application_code
  environment_code      = var.environment_code
  region_code           = var.region_code
  application_use       = "${var.application_use}"
  tags                  = var.tags
  
  # glue catalog database
  glue_database_name    = "connect-datalake-link"
  glue_catalog_map      = {}

  add_linked_database   = true
  target_catalog_id     = var.producer_catalog_id
  target_database_name  = var.source_database_name
}

# Module to create data base for views in Lake formation
module "glue_database_connect_datalake_views" {
  source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version               = "10.0.4"
  company_code          = var.company_code
  application_code      = var.application_code
  environment_code      = var.environment_code
  region_code           = var.region_code
  application_use       = "${var.application_use}"
  tags                  = var.tags

  # glue catalog database
  glue_database_name    = "connect-datalake-views"
  glue_catalog_map      = {}
}

# Create a resource link from Connect API
# module "glue_data_catalog_connect_api" {
#   source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version               = "10.0.4"
#   company_code          = var.company_code
#   application_code      = var.application_code
#   environment_code      = var.environment_code
#   region_code           = var.region_code
#   application_use       = "${var.application_use}"
#   tags                  = var.tags
  
#   # glue catalog database
#   glue_database_name    = "connect-api-link"
#   glue_catalog_map      = {}

#   add_linked_database   = true
#   target_catalog_id     = var.connect_api_catalog_id
#   target_database_name  = var.connect_api_db_name
# }


# # Create a resource link from CIS Main
# module "glue_data_catalog_customer_cismain" {
#   source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version               = "10.0.4"
#   company_code          = var.company_code
#   application_code      = var.application_code
#   environment_code      = var.environment_code
#   region_code           = var.region_code
#   application_use       = "${var.application_use}"
#   tags                  = var.tags
  
#   lifecycle {
#     create_before_destroy = false
#     ignore_changes        = all
#   }

#   # glue catalog database
#   glue_database_name    = "customer-cismain-link"
#   glue_catalog_map      = {}

#   add_linked_database   = true
#   target_catalog_id     = var.connect_api_catalog_id
#   target_database_name  = "sdge_dev_wus2_customer_cismain"
# }

# resource "aws_glue_catalog_database" "glue_data_catalog_customer_cismain" {
#   name         = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-customer-cismain-link"
#   catalog_id   = var.awsAccount
#   tags = var.tags
#   lifecycle {
#     ignore_changes = [
#       description
#     ]
#   }
#   target_database {
#     catalog_id    = var.connect_api_catalog_id
#     database_name = "sdge_${var.environment_code}_wus2_customer_cismain"
#   }
# }

resource "aws_glue_catalog_database" "glue_data_catalog_customer_connectchatbot" {
  name         = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-customer-connectchatbot-link"
  catalog_id   = var.awsAccount
  tags = var.tags
  lifecycle {
    ignore_changes = [
      description
    ]
  }

  // Optional Linked Database
  target_database {
    catalog_id    = var.connect_api_catalog_id
    database_name = var.connect_api_db_name
  }
}
