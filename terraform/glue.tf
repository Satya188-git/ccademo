module "gluecrawler_role" {
  source  = "app.terraform.io/SempraUtilities/seu-iam-role/aws"
  version = "10.0.2"
  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-gluecrawler"
  description       = "This is a Glue role to run NICE and Connect crawlers and update respective tables in Athena"
  service_resources = ["glue.amazonaws.com"]
  tags              = var.tags
}

resource "aws_iam_role_policy" "glue_policy" {
  name   = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-glue-crawler"
  role   = module.gluecrawler_role.name
  policy = templatefile("${path.module}/iampolicies/policy-iam-glue-assume-role.tmpl",{})
}

resource "aws_glue_catalog_database" "nice_glue_database" {
  name         = "nice_database_tf"
  description  = "Database to store data from NICE API using Lambda"
}

# resource "aws_glue_catalog_database" "connect_api_glue_database" {
#   name         = "connect_database_tf"
#   description  = "Database to store data from Connect API using Lambda"
# }


module "nice_gluecrawler" {
  source  = "app.terraform.io/SempraUtilities/seu-glue-crawler/aws"
  version = "10.0.0"

  company_code      = var.company_code
  application_code  = var.application_code
  environment_code  = var.environment_code
  region_code       = var.region_code
  application_use   = "${var.application_use}-nice-crawler"
  tags              = var.tags
  iam_role_arn  = module.gluecrawler_role.arn
  iam_role_name = module.gluecrawler_role.name

  glue_crawler_map = {
    crawler_s3 = {
      database_name = aws_glue_catalog_database.nice_glue_database.name
      
      s3_targets = {
        s3_target1 = {
          path = "s3://${module.s3_bucket_nice.s3_bucket_id}/"
        }
      }
      configuration = jsonencode(
        { 
          CreatePartitionIndex = "False"
          Version = 1
        })
      
      catalog_targets = {}
      dynamodb_targets = {}
      jdbc_targets = {}
      mongodb_targets = {}

      optional_arguments = {
        description            = "This crawler crawls the NICE Data generated from Lambda"
        schema_delete_behavior = "DEPRECATE_IN_DATABASE"
        schema_update_behavior = "UPDATE_IN_DATABASE"
        table_prefix = "${var.environment_code}_"
      } 
    }
    # crawler_s3 = {
    #   name          = "connect-api-crawler"
    #   database_name = aws_glue_catalog_database.connect_api_glue_database.name
      
    #   s3_targets = {
    #     s3_target1 = {
    #       path = "s3://${module.s3_bucket_nice.s3_bucket_id}/"
    #     }
    #   }

    #   catalog_targets = {}
    #   dynamodb_targets = {}
    #   jdbc_targets = {}
    #   mongodb_targets = {}

    #   optional_arguments = {
    #     description            = "This crawler crawls the CONNECT API Data generated from Lambda"
    #     schema_delete_behavior = "LOG"
    #     schema_update_behavior = "LOG"
    #     table_prefix = "${var.environment_code}_"
    #   }
    # } 
  }
}
