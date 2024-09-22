resource "aws_secretsmanager_secret" "nice_secrets_manager" {
    description                    = "Secrets Manager for NICE API Keys"
    kms_key_id                     = var.kms_key_id
    name                           = "${var.environment_code}/${var.application_use}/nice-tf"
    tags = var.tags
}