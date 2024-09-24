resource "aws_secretsmanager_secret" "nice_secrets_manager" {
    description                    = "Secrets Manager for NICE API Keys"
    name                           = "${var.environment_code}/${var.application_use}/nice-tf"
    tags = var.tags
}


resource "aws_secretsmanager_secret_version" "nice_secrets" {
  secret_id     = aws_secretsmanager_secret.nice_secrets_manager.id
  secret_string = jsonencode({
    nice_common_api_key = var.nice_common_api_key
    nice_hist_queuestats_key = var.nice_hist_queuestats_key
  })
}