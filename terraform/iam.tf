# IAM Role for lake formation
module "lakeformation_admin" {
  source            = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version           = "10.0.2"
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
  name = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-lf-policy"
  role = module.lakeformation_admin.name
  policy = templatefile(
    "${path.module}/iampolicies/policy-iam-lf-assume-role.tmpl",
    {}
  )
}

module "qs_reader" {
  source            = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version           = "10.0.2"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-qs-reader"
  description       = "QuickSight-Reader-Role"
  service_resources = ["*"]
  tags              = var.tags
  additional_policy_statements = [
    {
      "Effect" : "Allow",
      "Principal" : {
        "Federated" : "arn:aws:iam::${var.awsAccount}:saml-provider/AzureActiveDirectory"
      },
      "Action" : "sts:AssumeRoleWithSAML",
      "Condition" : {
        "StringEquals" : {
          "SAML:aud" : "https://signin.aws.amazon.com/saml"
        }
      }
    }
  ]
}

resource "aws_iam_policy" "qs_reader_policy" {
  name        = "QuickSight-Federated-Reader"
  description = "A policy for QuickSight-Reader-Role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "quicksight:CreateReader"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "qs_reader_policy_attachment" {
  role       = module.qs_reader.name
  policy_arn = aws_iam_policy.qs_reader_policy.arn
}
