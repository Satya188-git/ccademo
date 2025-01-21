awsAccount       = "977099013355"
environment_code = "prd"
company_code     = "sdge"
application_code = "dcctr"
region_code      = "wus2"
application_use  = "ccc-analytics"
tags = {
  "billing-guid"           = "BC4AD0602D58DD1889ED839BF5929FCA"
  "portfolio"              = "DCCTR"
  "support-group"          = "Distribution list in email format"
  "sempra:gov:environment" = "PRD"
  "sempra:gov:cmdb-ci-id"  = "APM1234567"
  "data-classification"    = "Data privacy classification ex: public sensitive confidential"
}

admins_arn = "arn:aws:iam::977099013355:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-prd-admin_7d5e22bb2ed0da3c"
devs_arn   = "arn:aws:iam::977099013355:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-prd-developer_7d2487b10d0b3a9b"
qs_arn     = "arn:aws:iam::977099013355:role/service-role/aws-quicksight-service-role-v0"
fondo_arn  = "arn:aws:iam::977099013355:role/fondo/sdge-dcctr-prd-terraform-oidc-role"

connect_catalog_id           = "632182196722"
connect_source_database_name = "connect_datalake"
connect_source_table_names = [
  "agent_statistic_record",
  "agent_queue_statistic_record",
  "contact_evaluation_record",
  "contact_flow_events",
  "contact_lens_conversational_analytics",
  "contact_record",
  "contact_statistic_record"
]

chatbot_catalog_id           = "685757275861"
chatbot_source_database_name = "sdge_dev_wus2_customer_connectchatbot"
chatbot_source_table_names = [
  "sdge_connect_aws_lambda_sdge_dhepk_sbx_wus2_lambda_einstein_lex_bot_faq_async",
  "sdge_connect_aws_lambda_sdge_dhepk_sbx_wus2_lambda_einstein_lex_bot_faq",
  "sdge_connect_aws_connect_sdge_dhepk_sbx_wus2_einstein_connect"
]


quicksight_user_arns = [
  "arn:aws:quicksight:us-west-2:977099013355:user/default/AWSReservedSSO_sdge-dcctr-prd-admin_7d5e22bb2ed0da3c/ATaylor2@sdge.com",
  "arn:aws:quicksight:us-west-2:977099013355:user/default/AWSReservedSSO_sdge-dcctr-prd-admin_7d5e22bb2ed0da3c/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:977099013355:user/default/AWSReservedSSO_sdge-dcctr-prd-admin_7d5e22bb2ed0da3c/RKadari@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:977099013355:user/default/AWSReservedSSO_sdge-dcctr-prd-admin_7d5e22bb2ed0da3c/SRacharl@sdgecontractor.com"
]

pandas_layer_arn          = "arn:aws:lambda:us-west-2:977099013355:layer:AWSSDKPandas-Python311:17"
code_artifact_bucket_name = "sdge-dcctr-prd-wus2-s3-artifacts"

ado_role_name = "sdge-dcctr-prd-iam-role-ado"
domain_name= "sdge.com"
zone_id = "Z033821811F9PN8CE1DQE"
