module "athena" {
    source  = "app.terraform.io/SempraUtilities/seu-athena/aws"
    version = "10.0.4"

    depends_on = [
        module.glue_data_catalog_connect_datalake,
        module.glue_database_connect_datalake_views,
        module.lake_formation
    ]
    company_code     = var.company_code
    application_code = var.application_code
    environment_code = var.environment_code
    region_code      = var.region_code
    application_use  = var.application_use
    tags             = var.tags

    # option to create Athena workgroup and corresponding variables
    # create_workgroup                   = true
    # workgroup_force_destroy            = true
    # workgroup_description              = "Example IaC Athena Workgroup"
    # enforce_workgroup_configuration    = true
    # publish_cloudwatch_metrics_enabled = true
    # output_location                    = "s3://${module.s3-bucket.s3_bucket_id}/output/"
    # workgroup_encryption_option        = "SSE_KMS"
    # workgroup_kms_key_arn              = aws_kms_key.athena_kms_key.arn

    # option to create Athena DB and corresponding variables
    # create_athena_database = true
    # db_force_destroy       = false
    # athena_db_name         = "iac_test_athena_db"
    # athena_database_bucket = module.s3-bucket.s3_bucket_id
    # db_encryption_option   = "SSE_KMS"
    # db_kms_key_arn         = aws_kms_key.athena_kms_key.arn

    create_workgroup       = false
    create_athena_database = false

    create_athena_named_query = true
    named_query_name          = "connectapi"
    named_query_description   = "Connect API data from Producer S3"
    named_query_workgroup     = "primary"
    named_query_database      = "sdge-dcctr-dev-wus2-glue-ccc-analytics-connect_datalake_views"
    #named_query_query         = "SELECT * FROM \"${module.glue-crawler.glue_database_name}\".\"test\" limit 10;"
    named_query_query = "SELECT * FROM \"sdge-dcctr-dev-wus2-gdc-ccc-analytics-connect_datalake_link\".\"contact_record\" limit 10;"


    # enable_monitoring = true
    # alarm_action      = module.sns.email_subscription_arn[0]
    # athena_alarm = [
    #   {
    #     alarm_name          = "athena-query-processed-bytes"
    #     comparison_operator = "GreaterThanOrEqualToThreshold"
    #     evaluation_periods  = 1
    #     metric_name         = "ProcessedBytes"
    #     namespace           = "AWS/Athena"
    #     period              = 300
    #     statistic           = "Sum"
    #     threshold           = 10240
    #     alarm_description   = "Alarm for Athena queryprocessed-bytes exceeding 10 KB"
    #     alarm_action        = module.sns.email_subscription_arn[0]
    #   },
    #   // Add more alarms as needed
    # ]
}   