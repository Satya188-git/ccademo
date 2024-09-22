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
