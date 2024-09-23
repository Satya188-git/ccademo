module "lake-formation-nice" {
  source  = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version = "9.1.1"

  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use
  depends_on =  [aws_glue_catalog_database.nice_glue_database]

  set_glue_data_catalog_permissions = true

  s3_arns = []

  assign_iam_admin    = true
  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name

  
}

