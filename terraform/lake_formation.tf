module "lake-formation-nice" {
  source  = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version = "9.1.1"

  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use

  depends_on = [aws_glue_catalog_database.nice_glue_database, module.lakeformation_admin]

  set_glue_data_catalog_permissions = true
  trusted_resource_owners           =  ["442426866507"]

  assign_iam_admin    = true

  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name
  
  sso_admin_role_arns = [module.lakeformation_admin.arn, var.admins_arn , var.devs_arn]
  sso_admin_role_names  = [module.lakeformation_admin.name, "AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f", "AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f"]

}


resource "aws_glue_catalog_table" "glue_table_links" {
  count = length(var.source_table_names)

  name          = "${element(var.source_table_names, count.index)}_link"
  database_name = aws_glue_catalog_database.nice_glue_database.name
  catalog_id    = var.catalog_id # AWS Account ID of the source catalog (external AWS account)

  table_type = "GOVERNED"  # This is important for resource links
  parameters = {
    "targetTable"     = jsonencode({
      "CatalogId"     = "632182196722"
      "DatabaseName"  = "connect_datalake"
      "Name"          = element(var.source_table_names, count.index)
    })
  }

  # Depends on the database creation
  depends_on = [aws_glue_catalog_database.nice_glue_database, module.lakeformation_admin]
}

# module "gdc_table" {
#   source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version = "10.0.4"
#   company_code      = var.company_code
#   application_code  = var.application_code
#   environment_code  = var.environment_code
#   region_code       = var.region_code
#   application_use   = "${var.application_use}-lf-gdc"
#   tags = var.tags
#   # glue catalog database
#   glue_database_name = "analytics_database"

#   add_linked_database = true
#   target_catalog_id = "632182196722"
#   target_database_name = "connect_datalake"

#   glue_catalog_map = {
#     "sample_table_1" = {
#       name                           = "sample_table_1"
#       glue_catalog_table_description = "Table created using LF in GDC"
#       # glue_catalog_table_table_type  = local.glue_catalog_table_table_type

#     }

    
#   }
# }