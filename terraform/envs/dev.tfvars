awsAccount       = "442426866507"
assume_role      = "arn:aws:iam::442426866507:role/fondo/sdge-dcctr-dev-iam-role-tfc"
environment_code = "dev"
company_code      = "sdge"
application_code  = "dcctr"
region_code       = "wus2"
application_use   = "ccc-analytics"
tags = {
    "billing-guid"           = "BC4AD0602D58DD1889ED839BF5929FCA"
    "portfolio"              = "DCCTR"
    "support-group"          = "Distribution list in email format"
    "sempra:gov:environment" = "DEV"
    "sempra:gov:cmdb-ci-id"  = "APM1234567"
    "data-classification"    = "Data privacy classification ex: public sensitive confidential"
  }

pandas_layer_arn = "arn:aws:lambda:us-west-2:336392948345:layer:AWSSDKPandas-Python311:17"
code_artifact_bucket_name = "sdge-dcctr-dev-wus2-s3-artifacts"

admins_arn = "arn:aws:iam::442426866507:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f"
devs_arn = "arn:aws:iam::442426866507:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f"
target_database_name = "analytics_database"
producer_catalog_id = "632182196722"
source_database_name = "connect_datalake"

nice_common_api_key  = "#{nice-common-api-key}#" 
nice_hist_queuestats_key  = "#{nice-hist-queuestats-key}#"

source_table_names = [
  "agent_statistic_record",
  "agent_queue_statistic_record",
  "contact_evaluation_record",
  "contact_flow_events",
  "contact_lens_conversational_analytics",
  "contact_record",
  "contact_statistic_record"
 ]
