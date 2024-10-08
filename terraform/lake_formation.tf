# Create Resource Link for Connect API
# resource "aws_glue_catalog_database" "glue_connect_api_link" {
#   lifecycle {
#     ignore_changes = [
#       description
#     ]
#   } 
#   name = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-api-link"
#   target_database {
#     catalog_id    = var.connect_api_catalog_id
#     database_name = var.connect_api_db_name
#   }
#   create_table_default_permission {
#     permissions = ["SELECT"]

#     principal {
#       data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
#     }
#   }
# }


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
                                      module.glue_data_catalog_connect_datalake,
                                      module.glue_database_connect_datalake_views,
                                      module.glue_data_catalog_customer_cismain
                                    ]

  # Adding DESCRIBE Permission on databases
  data_permission_map             = {
    permission1     = {
      type          = "database"
      principal     = var.devs_arn
      permissions   = ["DESCRIBE"]
      database_name = module.glue_data_catalog_connect_datalake.glue_catalog_database_name
    },
    permission2     = {
      type          = "database"
      principal     = var.devs_arn
      permissions   = ["DESCRIBE"]
      database_name = module.glue_database_connect_datalake_views.glue_catalog_database_name
    },
    permission3     = {
      type          = "database"
      principal     = var.devs_arn
      permissions   = ["DESCRIBE"]
      database_name = module.glue_data_catalog_customer_cismain.glue_catalog_database_name
    }
}



