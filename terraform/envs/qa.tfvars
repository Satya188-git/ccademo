awsAccount       = "619071332326"
assume_role      = "arn:aws:iam::619071332326:role/fondo/sdge-dcctr-dev-iam-role-tfc"
environment_code = "qa"
company_code      = "sdge"
application_code  = "dcctr"
region_code       = "wus2"
application_use   = "ccc-analytics"
tags = {
    "billing-guid"           = "BC4AD0602D58DD1889ED839BF5929FCA"
    "portfolio"              = "DCCTR"
    "support-group"          = "Distribution list in email format"
    "sempra:gov:environment" = "QA"
    "sempra:gov:cmdb-ci-id"  = "APM1234567"
    "data-classification"    = "Data privacy classification ex: public sensitive confidential"
  }

admins_arn = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f"
devs_arn = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f"

target_database_name = "analytics_database"
producer_catalog_id = "632182196722"
source_database_name = "connect_datalake"

source_table_names = [
  "agent_statistic_record",
  "agent_queue_statistic_record",
  "contact_evaluation_record",
  "contact_flow_events",
  "contact_lens_conversational_analytics",
  "contact_record",
  "contact_statistic_record"
 ]

quicksight_user_arns = [
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f/RKadari@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/AKumar45@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/SThodima@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f/SRacharl@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/IMishra@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/SRacharl@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/VWahal@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/HKumar3@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/PSharma6@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:442426866507:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f/SMothuku@sdgecontractor.com"
]

view_original_text = "CREATE OR REPLACE VIEW view_tf AS (SELECT * FROM sdge-dcctr-dev-wus2-gdc-ccc-analytics-connect_datalake_views.connectapi limit 10);"