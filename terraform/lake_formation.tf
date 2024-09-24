# Module to add SSO and admin roles to the Lake formation's Administrative roles and tasks

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

# Module to create database using Lake formation

module "gdc_table" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-lf"
  tags = var.tags
  # glue catalog database
  glue_database_name = "analytics_database"
  glue_catalog_map = {}

  # add_linked_database = true
  # target_catalog_id = var.producer_catalog_id
  # target_database_name = var.source_database_name

}