# resource "aws_ses_domain_identity" "reports" {
#   domain = var.r53_zone_name
# }

# resource "aws_ses_domain_dkim" "sdge_reports_dkim" {
#   domain = aws_ses_domain_identity.reports.domain
# }

# resource "aws_ses_domain_identity_verification" "ses_domain_verification" {
#   depends_on = [var.sdge_domain_identity_verification_record]
#   domain     = aws_ses_domain_identity.reports.id
# }

# data "aws_iam_policy_document" "ses_domain_identity_policy" {
#   statement {
#     actions   = ["SES:SendEmail", "SES:SendRawEmail"]
#     resources = [aws_ses_domain_identity.reports.arn]

#     principals {
#       identifiers = ["ses.amazonaws.com"]
#       type        = "Service"
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "aws:SourceAccount"
#       values   = ["${var.awsAccount}"]
#     }
#   }
# }

# resource "aws_ses_identity_policy" "pinpoint_domain_policy" {
#   identity = aws_ses_domain_identity.reports.arn
#   name     = "${var.application_use}_identity_policy"
#   policy   = data.aws_iam_policy_document.ses_domain_identity_policy.json
# }