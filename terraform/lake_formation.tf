# Module to add SSO and admin roles to the Lake formation's Administrative roles and tasks
module "lake_formation" {
  
  source                            = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version                           = "9.1.1"
  company_code                      = var.company_code
  application_code                  = var.application_code
  environment_code                  = var.environment_code
  region_code                       = var.region_code
  application_use                   = var.application_use

  set_glue_data_catalog_permissions = true
  use_lake_formation                = true

  assign_iam_admin                  = true
  trusted_resource_owners_id        = [var.connect_api_catalog_id, var.producer_catalog_id]

  iam_admin_role_arn                = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name               = data.aws_iam_session_context.current.issuer_name
  
  sso_admin_role_arns               = [ 
                                        module.lakeformation_admin.arn,
                                        var.admins_arn,
                                        var.devs_arn
                                      ]

  sso_admin_role_names              = [ 
                                        module.lakeformation_admin.name,
                                        element(split("/", var.admins_arn), length(split("/", var.admins_arn)) - 1),
                                        element(split("/", var.devs_arn), length(split("/", var.devs_arn)) - 1),
                                      ]
  depends_on                      = [
                                      module.lakeformation_admin,
                                      aws_glue_catalog_database.glue_data_catalog_connect_datalake,
                                      aws_glue_catalog_database.glue_database_connect_datalake_views,
                                      aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot
                                    ]

# Adding DESCRIBE Permission on databases
  data_permission_map             = {
    permission1     = {
      type          = "database"
      principal     = var.admins_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission2     = {
      type          = "database"
      principal     = var.admins_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission3     = {
      type          = "database"
      principal     = var.admins_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot.name
    },
    permission4     = {
      type          = "table"
      principal     = var.admins_arn
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission5     = {
      type          = "table"
      principal     = var.devs_arn
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission6     = {
      type          = "database"
      principal     = var.qs_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission7     = {
      type          = "table"
      principal     = var.qs_arn
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission8     = {
      type          = "database"
      principal     = var.qs_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    }
    # ,
    # permission9     = {
    #   type          = "table"
    #   principal     = var.qs_arn
    #   permissions   = ["SELECT"]
    #   database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    #   table_name  = "ivr_combined_2509data_ext_table"
    # }

  }
}

# resource "aws_lakeformation_permissions" "gdc_views_permissions" {
#   depends_on = [module.lakeformation_admin, module.glue_database_connect_datalake_views]
#   principal                     = "IAM_ALLOWED_PRINCIPALS"
#   permissions                   = ["SELECT"]
#   permissions_with_grant_option = ["SELECT"]
#   table {
#     database_name = module.glue_database_connect_datalake_views.glue_catalog_database_name
#     catalog_id = var.awsAccount
#     wildcard = true
#   }
# }

