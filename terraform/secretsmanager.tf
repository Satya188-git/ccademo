resource "aws_secretsmanager_secret" "nice_secrets_manager" {
    description                    = "Secrets Manager for NICE API Keys"
    name                           = "${var.environment_code}/${var.application_use}/nice-tf"
    tags = var.tags
}