variable "awsAccount" {
  description = "aws account number"
  type        = string
}

variable "assume_role" {
  description = "This is the role to be assumed by IaC's TF role. It will determine where the resources are built."
  type        = string
}

variable "environment_code" {
  type        = string
  description = "The environment code (e.g., DEV, QA, PROD) where the resources will be deployed."
}

variable "company_code" {
  description = "Company code"
  type        = string
}

variable "application_code" {
  description = "Application code"
  type        = string
}
variable "region_code" {
  description = "Region code"
  type        = string
}

variable "application_use" {
  description = "Application use"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources in this module."
}

variable "pandas_layer_arn" {
  type = string
  description = "AWSSDKPandas-Python311 Pandas Layer from AWS"
}

variable "code_artifact_bucket_name" {
  description = "S3 bucket name for code artifacts"
  type        = string
}
variable "kms_key_id" {
  description = "Default KMS encryption KEY ID for the Secrets Manager"
  type        = string
}

variable "nice_api_key" {
  description = "Nice API Key from ADO"
  type        = string
}

variable "nice_api_secret" {
  description = "Nice API Key from ADO"
  type        = string
}