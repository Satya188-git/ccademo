# SES Domain Identity
resource "aws_ses_domain_identity" "main" {
  domain = var.domain_name
}

# DKIM Configuration
resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}
 
# Configuration Set Association
resource "aws_ses_configuration_set" "default" {
  name = "default"
  lifecycle {
    ignore_changes = all
  }
}
 
# DKIM DNS Records
resource "aws_route53_record" "dkim" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${aws_ses_domain_identity.main.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
 
# Domain Verification Record
resource "aws_route53_record" "domain_verification" {
  zone_id = var.zone_id
  name    = "_amazonses.${aws_ses_domain_identity.main.domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.main.verification_token]
}
