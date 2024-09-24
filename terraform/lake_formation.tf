module "lake-formation-nice" {
  source  = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version = "9.1.1"

  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use

  set_glue_data_catalog_permissions = true

  s3_arns = []
  
  assign_iam_admin    = false
  
  sso_admin_role_arns = [var.admins_arn , var.devs_arn]
  sso_admin_role_names  = ["AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f", "AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f"]

}
module "gdc_table" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-lf-gdc"
  tags = var.tags
  # glue catalog database
  glue_database_name = "analytics_database"
  add_linked_database = true
  target_catalog_id = "632182196722"
  target_database_name = "connect_datalake"
  glue_catalog_map = {
    "sample_table_1" = {
      name                           = "sample_table_1"
      glue_catalog_table_description = "Table created using LF in GDC"
      # glue_catalog_table_table_type  = local.glue_catalog_table_table_type

    }

    
  }
}

# module "lf_role" {
#   source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
#   version = "10.0.2"
#   company_code      = var.company_code
#   application_code  = var.application_code
#   environment_code  = var.environment_code
#   region_code       = var.region_code
#   application_use   = "${var.application_use}-lake-formation"
#   description       = "This is a role for lake formation"
#   service_resources = ["glue.amazonaws.com"]
#   tags              = var.tags
# }

# module "glue-database" {
#   source  = "app.terraform.io/SempraUtilities/seu-glue-crawler/aws"
#   version = "10.1.0"
#   depends_on = [module.lake-formation-nice, module.lf_role]
#   company_code     = var.company_code
#   application_code = var.application_code
#   environment_code = var.environment_code
#   region_code      = var.region_code
#   application_use  = var.application_use

#   iam_role_arn  = module.gluecrawler_role.arn
#   iam_role_name = module.gluecrawler_role.name

#   glue_database_map = {
#     database1 = {
#       // job specific name here gets appended to standardized name
#       name = "analytics_database"
#       optional_arguments = {
#         description = "This is a common analytics database for both NICE and Connect Data"
#       }
#     }
#   }
#   tags = var.tags
# }

# resource "aws_glue_catalog_database" "glue_database_links" {
#   depends_on  = [module.lake-formation-nice]
#   description = "Lake formation database created using terraform"
#   name        = "${var.target_database_name}_link"
#   target_database {
#     database_name = var.target_database_name
#     catalog_id    = "AwsDataCatalog"
#   }
# }

# resource "aws_glue_catalog_table" "glue_table_links" {
#   count = length(var.source_table_names)

#   name          = "${element(var.source_table_names, count.index)}_link"
#   database_name = aws_glue_catalog_database.glue_database_links.name
#   catalog_id    = var.catalog_id # AWS Account ID of the source catalog (external AWS account)

#   table_type = "VIRTUAL_VIEW"  # This is important for resource links
#   parameters = {
#     "targetTable"     = jsonencode({
#       "CatalogId"     = var.catalog_id,             # The source AWS account ID
#       "DatabaseName"  = var.source_database_name,   # The source database name
#       "Name"          = element(var.source_table_names, count.index) # Table name in the source account
#     })
#     "EXTERNAL" = "TRUE"
#   }

#   # Depends on the database creation
#   depends_on = [aws_glue_catalog_database.glue_database_links]
# }


