# Create the database for connect data lake views
resource "aws_glue_catalog_database" "glue_database_connect_datalake_views_preprod" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-views-preprod"
  catalog_id = var.awsAccount
  tags       = var.tags
  lifecycle {
    ignore_changes = all
  }
}

# Create the resource link for connect datalake data
resource "aws_glue_catalog_database" "glue_data_catalog_connect_datalake_preprod" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-link-preprod"
  catalog_id = var.awsAccount
  tags       = var.tags
  lifecycle {
    ignore_changes = all
  }
}


# Create the tables for connect datalake data
resource "aws_glue_catalog_table" "shared_connect_cont_static_link_preprod" {
  name          = var.connect_source_table_names[6] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake_preprod.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[6] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_cont_record_link_preprod" {
  name          = var.connect_source_table_names[5] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake_preprod.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[5] # The original table name in the shared Glue database
  }
}