# Module to create connect data resource link in Lake formation
# Create a resource link from connect datalake
# module "glue_data_catalog_connect_datalake" {
#   source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version               = "10.0.4"
#   company_code          = var.company_code
#   application_code      = var.application_code
#   environment_code      = var.environment_code
#   region_code           = var.region_code
#   application_use       = "${var.application_use}"
#   tags                  = var.tags
  
#   # glue catalog database
#   glue_database_name    = "connect-datalake-link"
#   glue_catalog_map      = {}

#   # add_linked_database   = true
#   # target_catalog_id     = var.producer_catalog_id
#   # target_database_name  = var.source_database_name
# }

# Module to create data base for views in Lake formation
# module "glue_database_connect_datalake_views" {
#   source                = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version               = "10.0.4"
#   company_code          = var.company_code
#   application_code      = var.application_code
#   environment_code      = var.environment_code
#   region_code           = var.region_code
#   application_use       = "${var.application_use}"
#   tags                  = var.tags

#   # glue catalog database
#   glue_database_name    = "connect-datalake-views"
#   glue_catalog_map      = {}
# }

# Create the resource link for connect chatbot api data
resource "aws_glue_catalog_database" "glue_data_catalog_customer_connectchatbot" {
  name         = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-customer-connectchatbot-link"
  catalog_id   = var.awsAccount
  tags = var.tags
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}

# Create the resource link for connect chatbot api data
resource "aws_glue_catalog_database" "glue_database_connect_datalake_views" {
  name         = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-views"
  catalog_id   = var.awsAccount
  tags = var.tags
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}

# Create the resource link for connect chatbot api data
resource "aws_glue_catalog_database" "glue_data_catalog_connect_datalake" {
  name         = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-link"
  catalog_id   = var.awsAccount
  tags = var.tags
  lifecycle {
    ignore_changes = [
      description
    ]
  }
}

resource "aws_glue_catalog_table" "shared_connect_cont_static_link" {
  name          = "contact_statistic_record"  # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
 
  table_type = "LINK"
 
  target_table {
    catalog_id   = var.producer_catalog_id  # Replace with the AWS account ID where the original table resides
    database_name = var.source_database_name  # The original Glue database name in the other account
    name          = "contact_statistic_record"  # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_cont_record_link" {
  name          = "contact_record"  # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
 
  table_type = "LINK"
 
  target_table {
    catalog_id   = var.producer_catalog_id  # Replace with the AWS account ID where the original table resides
    database_name = var.source_database_name  # The original Glue database name in the other account
    name          = "contact_record"  # The original table name in the shared Glue database
  }
}