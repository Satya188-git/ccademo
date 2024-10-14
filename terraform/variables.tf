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

variable "connect_api_catalog_id"{
  description = "This is the producer data catalog id or AWS Account ID for Connect API Data"
  type = string
}

variable "connect_api_db_name"{
  description = "This is the database name in the producer account for connect api data"
  type = string
}