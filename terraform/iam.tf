# IAM Role for lake formation
module "lakeformation_admin" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-lake-formation"
  description       = "IAM role for Lake Formation"
  service_resources = ["glue.amazonaws.com"]
  tags              = var.tags
}

resource "aws_iam_role_policy" "lf_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-lf-policy"
  role   = module.lakeformation_admin.name
  policy = templatefile(
    "${path.module}/iampolicies/policy-iam-glue-assume-role.tmpl",
    {}
  )
}