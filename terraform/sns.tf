locals {
  email_selected_value = lookup(var.email_value_map, var.environment_code, ["${var.sns_email}"])
}

module "sns_alarms_email_topic" {
  source           = "app.terraform.io/SempraUtilities/seu-sns/aws"
  version          = "10.1.1"
  application_use  = "${var.application_use}-containment-alerts-alarms"
  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  tags             = var.tags

  name = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-containment-alerts-alarms"
  # kms_master_key_id     = var.sns_topic_key_id
  create_email_topic    = true # Must be set to true to enable email subscriptions
  email_subscriber_list = local.email_selected_value
}