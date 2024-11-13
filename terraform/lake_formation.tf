# Module to add SSO and admin roles to the Lake formation's Administrative roles and tasks
module "lake_formation" {

  source           = "app.terraform.io/SempraUtilities/seu-lake-formation/aws"
  version          = "9.1.1"
  company_code     = var.company_code
  application_code = var.application_code
  environment_code = var.environment_code
  region_code      = var.region_code
  application_use  = var.application_use

  set_glue_data_catalog_permissions = true
  use_lake_formation                = true

  assign_iam_admin           = true
  trusted_resource_owners_id = [var.chatbot_catalog_id, var.connect_catalog_id]

  iam_admin_role_arn  = data.aws_iam_session_context.current.issuer_arn
  iam_admin_role_name = data.aws_iam_session_context.current.issuer_name

  # iam_admin_role_arn  = "arn:aws:iam::${var.awsAccount}:role/fondo/${var.ado_role_name}"
  # iam_admin_role_name = var.ado_role_name

  sso_admin_role_arns = [
    module.lakeformation_admin.arn,
    var.admins_arn,
    var.devs_arn,
    module.lambda_role.arn,
    "arn:aws:iam::${var.awsAccount}:role/fondo/${var.ado_role_name}"
  ]

  sso_admin_role_names = [
    module.lakeformation_admin.name,
    element(split("/", var.admins_arn), length(split("/", var.admins_arn)) - 1),
    element(split("/", var.devs_arn), length(split("/", var.devs_arn)) - 1),
    module.lambda_role.name,
    var.ado_role_name
  ]
  depends_on = [
    module.lakeformation_admin,
    aws_glue_catalog_database.glue_data_catalog_connect_datalake,
    aws_glue_catalog_database.glue_database_connect_datalake_views,
    aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot,
    module.lambda_role
  ]

  # Adding DESCRIBE Permission on databases
  data_permission_map = {
    # Connect Data Lake RL permissions
    permission1 = {
      type          = "database"
      principal     = var.admins_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission2 = {
      type          = "table"
      principal     = var.admins_arn
      permissions   = ["SELECT", "ALTER"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission3 = {
      type          = "database"
      principal     = var.devs_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission4 = {
      type          = "table"
      principal     = var.devs_arn
      permissions   = ["SELECT", "ALTER"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission5 = {
      type          = "database"
      principal     = var.qs_arn
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission6 = {
      type          = "table"
      principal     = var.qs_arn
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    # Connect DL Views RL permissions
    permission7 = {
      type          = "database"
      principal     = var.admins_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission8 = {
      type          = "table"
      principal     = var.admins_arn
      permissions   = ["SELECT", "ALTER"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
      wildcard      = true
    },
    permission9 = {
      type          = "database"
      principal     = var.devs_arn
      permissions   = ["DESCRIBE", "ALTER", "DROP"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission10 = {
      type          = "table"
      principal     = var.devs_arn
      permissions   = ["SELECT", "ALTER"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
      wildcard      = true
    },
    permission11 = {
      type          = "database"
      principal     = var.qs_arn
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission12 = {
      type          = "table"
      principal     = var.qs_arn
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
      wildcard      = true
    },
    # QS User level permissions
    permission13 = {
      type          = "database"
      principal     = var.quicksight_user_arns[0]
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    permission14 = {
      type          = "table"
      principal     = var.quicksight_user_arns[0]
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
      wildcard      = true
    },
    permission15 = {
      type          = "database"
      principal     = var.quicksight_user_arns[0]
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission16 = {
      type          = "table"
      principal     = var.quicksight_user_arns[0]
      permissions   = ["SELECT"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
      wildcard      = true
    },
    # IAMAllowedPrincipal
    permission17     = {
      type          = "database"
      principal     = "IAM_ALLOWED_PRINCIPALS"
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    },
    permission18     = {
      type          = "database"
      principal     = "IAM_ALLOWED_PRINCIPALS"
      permissions   = ["DESCRIBE"]
      database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    },
    # Containment Alerts role permissions
    # permission19 = {
    #   type          = "database"
    #   principal     = module.lambda_role.arn
    #   permissions   = ["DESCRIBE"]
    #   database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    # },
    # permission20 = {
    #   type          = "table"
    #   principal     = module.lambda_role.arn
    #   permissions   = ["SELECT"]
    #   database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    #   wildcard      = true
    # },
    # permission21 = {
    #   type          = "database"
    #   principal     = module.lambda_role.arn
    #   permissions   = ["DESCRIBE"]
    #   database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    # },
    # permission22 = {
    #   type          = "table"
    #   principal     = module.lambda_role.arn
    #   permissions   = ["SELECT"]
    #   database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
    #   wildcard      = true
    # },
  }
}

resource "aws_lakeformation_permissions" "ivr_call_events_permissions" {
  depends_on = [module.lakeformation_admin, aws_glue_catalog_database.glue_database_connect_datalake_views]
  principal                     = "IAM_ALLOWED_PRINCIPALS"
  permissions                   = ["SELECT", "ALTER"]
  table {
    database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    catalog_id    = var.awsAccount
    name          = "ivr_call_events"
  }
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_lakeformation_permissions" "ivr_call_transactions_permissions" {
  depends_on = [module.lakeformation_admin, aws_glue_catalog_database.glue_database_connect_datalake_views]
  principal                     = "IAM_ALLOWED_PRINCIPALS"
  permissions                   = ["SELECT", "ALTER"]
  table {
    database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    catalog_id    = var.awsAccount
    name          = "ivr_call_transactions"
  }
  lifecycle {
    ignore_changes = all
  }
}

# resource "aws_lakeformation_permissions" "ivr_call_transactions_lambda_permissions" {
#   depends_on = [module.lakeformation_admin, aws_glue_catalog_database.glue_database_connect_datalake_views]
#   principal                     = module.lambda_role.arn
#   permissions                   = ["SELECT", "ALTER"]
#   table {
#     database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
#     catalog_id    = var.awsAccount
#     name          = "ivr_call_transactions"
#   }
#   lifecycle {
#     ignore_changes = all
#   }
# }

resource "aws_lakeformation_permissions" "fcr_data_view_permissions" {
  depends_on = [module.lakeformation_admin, aws_glue_catalog_database.glue_database_connect_datalake_views]
  principal                     = "IAM_ALLOWED_PRINCIPALS"
  permissions                   = ["SELECT", "ALTER"]
  table {
    database_name = aws_glue_catalog_database.glue_database_connect_datalake_views.name
    catalog_id    = var.awsAccount
    name          = "fcr_data_view"
  }
  lifecycle {
    ignore_changes = all
  }
}
