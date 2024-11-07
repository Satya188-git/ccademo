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


# variable "kms_key_id" {
#   description = "Default KMS encryption KEY ID for the Secrets Manager"
#   type        = string
# }

variable "admins_arn" {
  description = "This variable is for adding admin arn into lake formation policies"
  type        = string
}

variable "devs_arn" {
  description = "This variable is for adding dev arn into lake formation policies"
  type        = string
}

variable "qs_arn" {
  description = "This variable is for adding qs arn into lake formation policies"
  type        = string
}

variable "fondo_arn" {
  description = "This variable is for adding qs arn into lake formation policies"
  type        = string
}
variable "connect_catalog_id" {
  description = "This is the connect producer data catalog id or AWS Account ID"
  type        = string
}

variable "connect_source_database_name" {
  description = "This is the database name in the connect producer account"
  type        = string
}

variable "connect_source_table_names" {
  description = "List of source table names that needs to be fetched from producer for connect db"
  type        = list(string)
}
variable "quicksight_user_arns" {
  description = "List of QS user arns to whome table permissions needs to be assigned"
  type        = list(string)
}

variable "chatbot_catalog_id" {
  description = "This is the producer data catalog id or AWS Account ID for Chatbot Data"
  type        = string
}

variable "chatbot_source_database_name" {
  description = "This is the database name in the producer account for connect chatbot data"
  type        = string
}

variable "chatbot_source_table_names" {
  description = "List of chatbot tables to be consumed from the source database"
  type        = list(string)
}

variable "pandas_layer_arn" {
  description = "This is the AWS provided ARN for pandas module, it can be imported in lambda"
  type        = string
}
variable "code_artifact_bucket_name" {
  description = "This is the AWS S3 bucket to store lambda artifacts"
  type        = string
}
