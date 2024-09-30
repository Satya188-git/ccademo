# Module to create connect data resource link in Lake formation
# Create a resource link from connect datalake
module "glue_data_catalog_connect_datalake" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}"
  tags = var.tags
  # glue catalog database
  glue_database_name = "connect_datalake_link"
  glue_catalog_map = {}

  add_linked_database = true
  target_catalog_id = var.producer_catalog_id
  target_database_name = var.source_database_name
}

# Module to create data base for views in Lake formation

module "glue_database_connect_datalake_views" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-data-catalog/aws"
  version = "10.0.4"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}"
  tags = var.tags

  # glue catalog database
  glue_database_name = "connect_datalake_views"
  glue_catalog_map = {
    "connectapi" = {
      name                           = "connectapi"
      glue_catalog_table_description = "Table created using TF for connect api data"
      glue_catalog_table_table_type  = "EXTERNAL"
      glue_catalog_table_parameters = {
        "classification" = "csv"
      }
      location                  = "s3://sdge-dhepk-sbx-wus2-s3-einstein-aws-connect/RealTimeMetrics/"
      input_format              = "org.apache.hadoop.mapred.TextInputFormat"
      output_format             = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
      compressed                = false
      # number_of_buckets         = "1"
      stored_as_sub_directories = "false"
      storage_descriptor_columns = [
        {
          columns_name    = "queue_id"
          columns_type    = "string"
          columns_comment = "queue_id"
        },
        {
          columns_name    = "metrics"
          columns_type    = "string"
          columns_comment = "metrics"
        },
        {
          columns_name    = "metric_value"
          columns_type    = "float"
          columns_comment = "metric_value"
        },
        {
          columns_name    = "language"
          columns_type    = "string"
          columns_comment = "language"
        },
        {
          columns_name    = "type"
          columns_type    = "string"
          columns_comment = "type"
        },
        {
          columns_name    = "ess2"
          columns_type    = "string"
          columns_comment = "ess2"
        },
      ]
      storage_descriptor_ser_de_info = [
        {
          ser_de_info_name                  = "my-stream"
          ser_de_info_serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
          ser_de_info_parameters            = tomap({"field.delim" = ",","skip.header.line.count" = "1" })
        },
      ]
    }

    "ivr_combined_data" = {
      name                           = "ivr_combined_data"
      glue_catalog_table_description = "IVR Combined data based on date filter"
      glue_catalog_table_view_original_text = var.view_original_text
      glue_catalog_table_view_expanded_text = var.view_original_text
      glue_catalog_table_table_type  = "VIRTUAL_VIEW"
      # glue_catalog_table_parameters = {
      #   "classification" = "csv",

      # }
      # location                  = "s3://my-bucket/event-streams/my-stream"
      # input_format              = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
      # output_format             = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
      # compressed                = "true"
      # number_of_buckets         = "1"
      # bucket_columns            = tolist(["test"])
      # parameters                = tomap({ "test" = "test" })
      stored_as_sub_directories = "false"
      storage_descriptor_columns = [
        {
          columns_name    = "queue_id"
          columns_type    = "string"
          columns_comment = "queue_id"
        },
        {
          columns_name    = "metrics"
          columns_type    = "string"
          columns_comment = "metrics"
        },
        {
          columns_name    = "metric_value"
          columns_type    = "float"
          columns_comment = "metric_value"
        },
        {
          columns_name    = "language"
          columns_type    = "string"
          columns_comment = "language"
        },
        {
          columns_name    = "type"
          columns_type    = "string"
          columns_comment = "type"
        },
        {
          columns_name    = "ess2"
          columns_type    = "string"
          columns_comment = "ess2"
        },
      ]
    }
  }
}