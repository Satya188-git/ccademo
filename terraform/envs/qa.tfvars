awsAccount       = "619071332326"
environment_code = "qa"
company_code     = "sdge"
application_code = "dcctr"
region_code      = "wus2"
application_use  = "ccc-analytics"
tags = {
  "billing-guid"           = "BC4AD0602D58DD1889ED839BF5929FCA"
  "portfolio"              = "DCCTR"
  "support-group"          = "Distribution list in email format"
  "sempra:gov:environment" = "QA"
  "sempra:gov:cmdb-ci-id"  = "APM1234567"
  "data-classification"    = "Data privacy classification ex: public sensitive confidential"
}

admins_arn = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-qa-admin_39b96139a7d09053"
devs_arn   = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-qa-developer_946c306c9d5c3025"
qs_arn     = "arn:aws:iam::619071332326:role/service-role/aws-quicksight-service-role-v0"
fondo_arn  = "arn:aws:iam::619071332326:role/fondo/sdge-dcctr-qa-terraform-oidc-role"

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
chatbot_source_database_name = "sdge_qa_wus2_customer_connectcloudwatchlogs"
chatbot_source_table_names = [
  "sdge_connect_aws_lambda_sdge_dhepk_tst_wus2_lambda_einstein_lex_bot_faq_async",
  "sdge_connect_aws_lambda_sdge_dhepk_tst_wus2_lambda_einstein_lex_bot_faq",
  "sdge_connect_aws_connect_sdge_dhepk_tst_wus2_einstein_connect",
  "sdge_connect_aws_lambda_sdge_dhepk_tst_wus2_lambda_einstein_civr_fulfillment"
]


quicksight_user_arns = [
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-qa-admin_39b96139a7d09053/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-qa-admin_39b96139a7d09053/RKadari@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-qa-admin_39b96139a7d09053/SRacharl@sdgecontractor.com"
]

pandas_layer_arn          = "arn:aws:lambda:us-west-2:336392948345:layer:AWSSDKPandas-Python311:17"
code_artifact_bucket_name = "sdge-dcctr-qa-wus2-s3-artifacts"

ado_role_name = "sdge-dcctr-qa-iam-role-ado"
domain_name= "sdge.com"
zone_id = "Z0334635S1UNUYEONFRH"
recipients = ["SThodima@sdgecontractor.com"]
