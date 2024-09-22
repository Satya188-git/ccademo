module "eventbridge_role" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"

  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-eventbridge"
  description       = "This is a event bridge scheduler role to schedule the NICE Lambda"
  service_resources = ["scheduler.amazonaws.com"]
  tags              = var.tags
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-eventbridge"
  role   = module.eventbridge_role.name
  policy = templatefile(
    "${path.module}/iampolicies/policy-iam-eventbrdige-assume-role.tmpl",{})
}

resource "aws_scheduler_schedule" "nice_eventbridge_scheduler" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-nice-scheduler"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(12 minutes)"
  
  target {
    arn      = module.nice_lambda.lambda_function_arn
    role_arn = module.eventbridge_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts = 2
    }
  }

}