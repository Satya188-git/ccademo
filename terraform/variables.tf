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

# variable "kms_key_id" {
#   description = "Default KMS encryption KEY ID for the Secrets Manager"
#   type        = string
# }


variable "nice_common_api_key" {
  description = "Nice Common API Key from ADO"
  type        = string
}

variable "nice_hist_queuestats_key" {
  description = "Nice API Key hist queue stats from ADO"
  type        = string
}


variable "admins_arn" {
  description = "This variable is for adding admin arn into lake formation policies"
  type        = string
}

variable "devs_arn" {
  description = "This variable is for adding dev arn into lake formation policies"
  type        = string
}

variable "target_database_name"{
  description = "This is the database names suffix to hold all the data for Nice and Connect in Lake formation"
  type = string
}

variable "producer_catalog_id"{
  description = "This is the producer data catalog id or AWS Account ID"
  type = string
}

variable "source_database_name"{
  description = "This is the database name in the producer account"
  type = string
}

variable "source_table_names" {
  description = "List of source table names that needs to be fetched from producer"
  type        = list(string)
}
variable "quicksight_user_arns"{
  description = "List of QS user arns to whome table permissions needs to be assigned"
  type        = list(string)
}