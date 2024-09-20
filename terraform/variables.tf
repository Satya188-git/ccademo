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

variable "serverless_application_zip" {
  description = "Serverless application zip file stored in S3 bucket. This is used as the S3 key"
  type        = string
}