
resource "aws_scheduler_schedule" "nice_eventbridge_scheduler" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-nice-scheduler"
  group_name = "default"
  depends_on = [ module.nice_lambda, module.eventbridge_role ]
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