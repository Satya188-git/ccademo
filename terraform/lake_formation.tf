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
  depends_on = [module.lakeformation_admin, module.glue_data_catalog_connect_datalake, module.glue_database_connect_datalake_views ]

  # set_glue_data_catalog_permissions = true
  set_glue_data_catalog_permissions = false
  use_lake_formation = true

  assign_iam_admin    = true
  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name
  
  sso_admin_role_arns = [ var.admins_arn , var.devs_arn]
  sso_admin_role_names  = [
    module.lakeformation_admin.arn,
    element(split("/", var.admins_arn), length(split("/", var.admins_arn)) - 1),
    element(split("/", var.devs_arn), length(split("/", var.devs_arn)) - 1),
  ]

  data_permission_map = {
    permission1 = {
      count         = length(var.quicksight_user_arns)
      type          = "database"
      # principal     = module.glue_data_catalog_connect_datalake.arn
      principal     = element(var.quicksight_user_arns, count.index)
      permissions   = ["DESCRIBE"]
      database_name = module.glue_data_catalog_connect_datalake.glue_catalog_database_name
    }
    permission2 = {
      count         = length(var.quicksight_user_arns)
      type          = "table"
      principal     = element(var.quicksight_user_arns,count.index)
      permissions   = ["SELECT"]
      principal     = element(var.quicksight_user_arns, floor(count.index / length(var.source_table_names)))
      wildcard      = true
    }
  }
}



