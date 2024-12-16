# data "aws_route53_zone" "public_zone" {
#   name         = var.domain_name
#   private_zone = false
# }

# SES Domain Identity
resource "aws_ses_domain_identity" "domain" {
  domain = var.domain_name
}

# DKIM Tokens
resource "aws_ses_domain_dkim" "dkim_token" {
  domain = aws_ses_domain_identity.domain.domain
}

# Domain Verification Records (DNS)
resource "aws_route53_record" "ses_verification" {
  zone_id = var.zone_id # Replace with your Route 53 Hosted Zone ID
  name    = aws_ses_domain_identity.domain.verification_token
  type    = "TXT"
  ttl     = 600
  records = [aws_ses_domain_identity.domain.verification_token]
}

# # DKIM Records
# resource "aws_route53_record" "ses_dkim" {
#   for_each = toset(aws_ses_domain_dkim.dkim_token.dkim_tokens)
#   zone_id  = var.zone_id # Replace with your Route 53 Hosted Zone ID
#   name     = "${each.value}._domainkey.${var.domain_name}"
#   type     = "CNAME"
#   ttl      = 600
#   records  = ["${each.value}.dkim.amazonses.com"]
# }

# DKIM Records
resource "aws_route53_record" "ses_dkim" {
  for_each = { for idx, value in aws_ses_domain_dkim.dkim_token.dkim_tokens : value => value }

  zone_id  = var.zone_id
  name     = "${each.key}._domainkey.${var.domain_name}"
  type     = "CNAME"
  ttl      = 600
  records  = ["${each.key}.dkim.amazonses.com"]
}

# # Domain Verification Record (TXT)
# resource "aws_route53_record" "ses_verification" {
#   zone_id = "Z123456789" # Replace with your Route 53 Hosted Zone ID
#   name    = "_amazonses.${aws_ses_domain_identity.example.domain}"
#   type    = "TXT"
#   ttl     = 300
#   records = [aws_ses_domain_identity.example.verification_token]
# }
 
# # DKIM CNAME Records
# resource "aws_route53_record" "ses_dkim" {
#   for_each = toset(aws_ses_domain_dkim.example.dkim_tokens)
#   zone_id  = "Z123456789" # Replace with your Route 53 Hosted Zone ID
#   name     = "${each.value}._domainkey.${aws_ses_domain_identity.example.domain}"
#   type     = "CNAME"
#   ttl      = 300
# records = ["${each.value}.dkim.amazonses.com"]
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



