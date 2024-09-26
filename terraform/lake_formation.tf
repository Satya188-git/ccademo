# Module to add SSO and admin roles to the Lake formation's Administrative roles and tasks

module "lake_formation_nice" {
  source  = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version = "9.1.1"

  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use

  # depends_on = [aws_glue_catalog_database.nice_glue_database, module.lakeformation_admin]
  depends_on = [module.lakeformation_admin]

  # set_glue_data_catalog_permissions = true
  set_glue_data_catalog_permissions = false
  use_lake_formation = true

  assign_iam_admin    = true
  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name
  
  sso_admin_role_arns = [module.lakeformation_admin.arn, var.admins_arn , var.devs_arn]
  sso_admin_role_names  = [
    module.lakeformation_admin.name,
    element(split("/", var.admins_arn), length(split("/", var.admins_arn)) - 1),
    element(split("/", var.devs_arn), length(split("/", var.devs_arn)) - 1),
  ]
}

# Module to create database and tables using Lake formation

module "glue_data_catalog" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}"
  tags = var.tags
  # glue catalog database
  glue_database_name = "connect_database"
  glue_catalog_map = {}

  add_linked_database = true
  target_catalog_id = var.producer_catalog_id
  target_database_name = var.source_database_name
}

# resource "aws_glue_catalog_table" "glue_table_links" {

#   count = length(var.source_table_names)
#   name          = "${element(var.source_table_names, count.index)}_link"
#   database_name = module.glue_data_catalog.glue_catalog_database_name
#   catalog_id    = var.producer_catalog_id # AWS Account ID of the source catalog (external AWS account)

#   table_type = "GOVERNED"  # This is important for resource links
#   parameters = {
#     "targetTable"     = jsonencode({
#       "CatalogId"     = var.producer_catalog_id
#       "DatabaseName"  = var.source_database_name
#       "Name"          = element(var.source_table_names, count.index)
#     })
#   }

#   # Depends on the database creation
#   depends_on = [module.glue_data_catalog, module.lakeformation_admin, module.lake_formation_nice]
# }


# resource "aws_lakeformation_permissions" "example" {
#   permissions = ["SELECT"]
#   principal   = "arn:aws:iam:us-east-1:123456789012:user/SanHolo"

#   table_with_columns {
#     database_name = aws_glue_catalog_table.example.database_name
#     name          = aws_glue_catalog_table.example.name
#     column_names  = ["event"]
#   }
# }


##############################        New Changes             #######################################
# resource "aws_lakeformation_permissions" "describe_permissions" {
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["DESCRIBE"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   resource {
#     data_lake_principal {
#       data_lake_principal_identifier = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
#     }
#     table_with_columns {
#       database_name = module.glue_data_catalog.glue_catalog_database_name
#       name          = element(var.source_table_names, count.index % length(var.source_table_names))
#     }
#   }
# }

# resource "aws_lakeformation_permissions" "select_permissions" {
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["SELECT"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   resource {
#     table_with_columns {
#       database_name = module.glue_data_catalog.glue_catalog_database_name
#       name          = element(var.source_table_names, count.index % length(var.source_table_names))
#     }
#   }
# }

##############################        New Changes             #######################################

# resource "aws_lakeformation_permissions" "describe_permissions" {
#   depends_on = [module.lakeformation_admin, module.glue_data_catalog, module.lakeformation_admin]
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["DESCRIBE"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   table {
#     database_name = module.glue_data_catalog.glue_catalog_database_name
#     name          = element(var.source_table_names, count.index % length(var.source_table_names))
#   }
# }

# resource "aws_lakeformation_permissions" "select_permissions" {
#   depends_on = [module.lakeformation_admin, module.glue_data_catalog, module.lakeformation_admin]
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["SELECT"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   table {
#     database_name = module.glue_data_catalog.glue_catalog_database_name
#     name          = element(var.source_table_names, count.index % length(var.source_table_names))
#   }
# }


##### Not working ##############
# resource "aws_lakeformation_permissions" "describe_permissions" {
#   depends_on = [module.glue_data_catalog]
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["DESCRIBE"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   table_with_columns {
#     database_name = "sdge-dcctr-dev-wus2-gdc-ccc-analytics-connect_database"
#     name          = element(var.source_table_names, count.index % length(var.source_table_names))
#     column_names  = ["*"]
# }

# }

# resource "aws_lakeformation_permissions" "select_permissions" {
#   depends_on = [module.glue_data_catalog, resource.aws_lakeformation_permissions.describe_permissions]
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   permissions = ["SELECT"]

#   principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  
#   table_with_columns {
#     database_name = "sdge-dcctr-dev-wus2-gdc-ccc-analytics-connect_database"
#     name          = element(var.source_table_names, count.index % length(var.source_table_names))
#     column_names  = ["*"]
# }
# }

resource "aws_lakeformation_permissions" "database" {
  count       = length(var.quicksight_user_arns)
  depends_on = [module.glue_data_catalog]
  principal                     = element(var.quicksight_user_arns, count.index )
  permissions                   = ["DESCRIBE"]
  permissions_with_grant_option = ["DESCRIBE"]
  database {
    name = module.glue_data_catalog.glue_catalog_database_name
    catalog_id = var.awsAccount
  }
}

# resource "aws_lakeformation_permissions" "table" {
#   depends_on = [module.glue_data_catalog, resource.aws_lakeformation_permissions.database]
#   count       = length(var.quicksight_user_arns) * length(var.source_table_names)
#   principal                     = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
#   permissions                   = ["SELECT"]
#   permissions_with_grant_option = ["SELECT"]
#   table {
#     database_name = module.glue_data_catalog.glue_catalog_database_name
#     name          = element(var.source_table_names, count.index % length(var.source_table_names))
#     catalog_id = var.awsAccount
#   }
# }