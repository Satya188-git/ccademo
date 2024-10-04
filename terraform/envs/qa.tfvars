awsAccount        = "619071332326"
assume_role       = "arn:aws:iam::619071332326:role/fondo/sdge-dcctr-dev-iam-role-tfc"
environment_code  = "qa"
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

admins_arn = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-qa-admin_39b96139a7d09053"
devs_arn = "arn:aws:iam::619071332326:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-qa-developer_946c306c9d5c3025"

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
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_39b96139a7d09053/RKadari@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_39b96139a7d09053/SRacharl@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-admin_39b96139a7d09053/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/AKumar45@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/SThodima@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/SNayak1@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/IMishra@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/SRacharl@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/VWahal@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/HKumar3@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/PSharma6@sdgecontractor.com",
  "arn:aws:quicksight:us-west-2:619071332326:user/default/AWSReservedSSO_sdge-dcctr-dev-developer_946c306c9d5c3025/SMothuku@sdgecontractor.com"
]
