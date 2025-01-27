resource "aws_scheduler_schedule" "cra_eventbridge_scheduler" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-cra-scheduler"
  group_name = "default"
  depends_on = [ module.containment_alerts_lambda, module.eventbridge_role ]
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 6 * * ? *)"
  schedule_expression_timezone = "America/Los_Angeles"
  
  target {
    arn      = module.containment_alerts_lambda.lambda_function_arn
    role_arn = module.eventbridge_role.arn
    retry_policy {
      maximum_event_age_in_seconds = 300
      maximum_retry_attempts = 2
    }
  }

}