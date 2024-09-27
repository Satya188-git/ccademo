data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

# Module to add SSO and admin roles to the Lake formation's Administrative roles and tasks
module "lake_formation" {
  source  = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version = "9.1.1"

  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use

  # depends_on = [aws_glue_catalog_database.nice_glue_database, module.lakeformation_admin]
  # depends_on = [module.lakeformation_admin]

  # set_glue_data_catalog_permissions = true
  set_glue_data_catalog_permissions = false
  use_lake_formation = false

  assign_iam_admin    = true
  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name
  
  sso_admin_role_arns = [ var.admins_arn , var.devs_arn]
  sso_admin_role_names  = [
    module.lakeformation_admin.arn,
    element(split("/", var.admins_arn), length(split("/", var.admins_arn)) - 1),
    element(split("/", var.devs_arn), length(split("/", var.devs_arn)) - 1),
  ]
}

# Module to create database and tables using Lake formation

# module "glue_data_catalog" {
#   source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version = "10.0.4"
#   company_code      = var.company_code
#   application_code  = var.application_code
#   environment_code  = var.environment_code
#   region_code       = var.region_code
#   application_use   = "${var.application_use}"
#   tags = var.tags
#   # glue catalog database
#   glue_database_name = "connect_database_link"
#   glue_catalog_map = {}

#   add_linked_database = true
#   target_catalog_id = var.producer_catalog_id
#   target_database_name = var.source_database_name
  
#   lifecycle {
#     create_before_destroy = true
#     ignore_changes        = []
#   }
# }

resource "aws_glue_catalog_database" "glue_database_links" {
  depends_on  = [module.lake_formation]
  name        = "${var.source_database_name}_link"
  target_database {
    database_name = var.source_database_name
    catalog_id    = var.producer_catalog_id
  }
}

resource "aws_lakeformation_permissions" "database" {
  count       = length(var.quicksight_user_arns)
  depends_on = [module.lakeformation_admin, resource.aws_glue_catalog_database.glue_database_links]
  principal                     = element(var.quicksight_user_arns, count.index )
  permissions                   = ["DESCRIBE"]
  permissions_with_grant_option = ["DESCRIBE"]
  database {
    name = resource.aws_glue_catalog_database.glue_database_links.name
    catalog_id = var.awsAccount
  }
}

resource "aws_lakeformation_permissions" "table" {
  depends_on = [module.lakeformation_admin, resource.aws_glue_catalog_database.glue_database_links, resource.aws_lakeformation_permissions.database]
  count       = length(var.quicksight_user_arns) * length(var.source_table_names)
  principal = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
  permissions = ["SELECT"]
  permissions_with_grant_option = ["SELECT"]
  table {
    # database_name = resource.aws_glue_catalog_database.glue_database_links.name
    database_name = var.source_database_name
    name          = element(var.source_table_names, count.index)
    # catalog_id = var.awsAccount
  }
}

# Module to create database and tables using Lake formation

# module "glue_data_catalog" {
#   source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
#   version = "10.0.4"
#   company_code      = var.company_code
#   application_code  = var.application_code
#   environment_code  = var.environment_code
#   region_code       = var.region_code
#   application_use   = "${var.application_use}"
#   tags = var.tags
#   # glue catalog database
#   glue_database_name = "connect_database_test"
#   glue_catalog_map = {}

#   add_linked_database = true
#   target_catalog_id = var.producer_catalog_id
#   target_database_name = var.source_database_name
# }


