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


admins_arn = "arn:aws:iam::442426866507:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-admin_f4611a12900c932f"
devs_arn = "arn:aws:iam::442426866507:role/aws-reserved/sso.amazonaws.com/us-west-2/AWSReservedSSO_sdge-dcctr-dev-developer_e540a5b0e1ae0e8f"

producer_catalog_id = "632182196722"
source_database_name = "connect_datalake"

connect_api_catalog_id = "685757275861"
connect_api_db_name = "sdge_dev_wus2_customer_connectchatbot"

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
