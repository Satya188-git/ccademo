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

  assign_iam_admin    = true
  iam_admin_role_arn  = [var.admins_arn , devs_arn]
  iam_admin_role_name = [element(split("/", var.admins_arn), 7), element(split("/", var.devs_arn), 7)]

}

resource "aws_glue_catalog_database" "glue_database_links" {
  depends_on  = [module.lake-formation-nice]
  description = "Lake formation database created using terraform"
  name        = "${var.target_database_name}_link"
  target_database {
    database_name = var.target_database_name
    catalog_id    = "AwsDataCatalog"
  }
}

resource "aws_glue_catalog_table" "glue_table_links" {
  count = length(var.source_table_names)

  name          = "${element(var.source_table_names, count.index)}_link"
  database_name = aws_glue_catalog_database.glue_database_links.name
  catalog_id    = var.catalog_id # AWS Account ID of the source catalog (external AWS account)

  table_type = "VIRTUAL_VIEW"  # This is important for resource links
  parameters = {
    "targetTable"     = jsonencode({
      "CatalogId"     = var.catalog_id,             # The source AWS account ID
      "DatabaseName"  = var.source_database_name,   # The source database name
      "Name"          = element(var.source_table_names, count.index) # Table name in the source account
    })
    "EXTERNAL" = "TRUE"
  }

  # Depends on the database creation
  depends_on = [aws_glue_catalog_database.glue_database_links]
}

