awsAccount       = "442426866507"
assume_role      = "arn:aws:iam::442426866507:role/fondo/sdge-dcctr-dev-iam-role-tfc"
environment_code = "dev"
company_code      = "sdge"
application_code  = "ccc"
region_code       = "wus2"
application_use   = "analytics"

tags = {
    "billing-guid"           = "BC4AD0602D58DD1889ED839BF5929FCA"
    "portfolio"              = "DCCTR"
    "support-group"          = "Distribution list in email format"
    "sempra:gov:environment" = "DEV"
    "sempra:gov:cmdb-ci-id"  = "APM1234567"
    "data-classification"    = "Data privacy classification ex: public sensitive confidential"
  }
serverless_application_zip = "Artifacts/dev/helloworld_serverless_package/helloworld-serverless.zip"
