# Module to create connect data resource link in Lake formation
# Create the resource link for connect chatbot data
# resource "aws_glue_catalog_database" "glue_data_catalog_customer_connectchatbot" {
#   name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-customer-connectchatbot-link"
#   catalog_id = var.awsAccount
#   tags       = var.tags
#   lifecycle {
#     ignore_changes = all
#   }
# }

# Create the database for connect data lake views
resource "aws_glue_catalog_database" "glue_database_connect_datalake_views" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-views"
  catalog_id = var.awsAccount
  tags       = var.tags
  lifecycle {
    ignore_changes = all
  }
}

# Create the resource link for connect datalake data
resource "aws_glue_catalog_database" "glue_data_catalog_connect_datalake" {
  name       = "${var.company_code}-${var.application_code}-${var.environment_code}-${var.region_code}-${var.application_use}-connect-datalake-link"
  catalog_id = var.awsAccount
  tags       = var.tags
  lifecycle {
    ignore_changes = all
  }
}

# Create the tables for connect datalake data
resource "aws_glue_catalog_table" "shared_connect_cont_static_link" {
  name          = var.connect_source_table_names[6] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[6] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_cont_record_link" {
  name          = var.connect_source_table_names[5] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[5] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_lens_conversational_analytics" {
  name          = var.connect_source_table_names[4] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[4] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_contact_flow_events" {
  name          = var.connect_source_table_names[3] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[3] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_contact_evaluation_record" {
  name          = var.connect_source_table_names[2] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[2] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_agent_queue_statistic_record" {
  name          = var.connect_source_table_names[1] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[1] # The original table name in the shared Glue database
  }
}

resource "aws_glue_catalog_table" "shared_connect_agent_statistic_record" {
  name          = var.connect_source_table_names[0] # Name for the resource link table
  database_name = aws_glue_catalog_database.glue_data_catalog_connect_datalake.name
  lifecycle {
    ignore_changes = all
  }
  table_type = "LINK"
  target_table {
    catalog_id    = var.connect_catalog_id            # Replace with the AWS account ID where the original table resides
    database_name = var.connect_source_database_name  # The original Glue database name in the other account
    name          = var.connect_source_table_names[0] # The original table name in the shared Glue database
  }
}

# Add the tables belonging to customer_connectchatbot
# resource "aws_glue_catalog_table" "shared_einstein_lex_bot_faq_async" {
#   name          = var.chatbot_source_table_names[0] # Name for the resource link table
#   database_name = aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot.name
#   lifecycle {
#     ignore_changes = all
#   }
#   table_type = "LINK"
#   target_table {
#     catalog_id    = var.chatbot_catalog_id            # Replace with the AWS account ID where the original table resides
#     database_name = var.chatbot_source_database_name  # The original Glue database name in the other account
#     name          = var.chatbot_source_table_names[0] # The original table name in the shared Glue database
#   }
# }
# resource "aws_glue_catalog_table" "shared_einstein_lex_bot_faq" {
#   name          = var.chatbot_source_table_names[1] # Name for the resource link table
#   database_name = aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot.name
#   lifecycle {
#     ignore_changes = all
#   }
#   table_type = "LINK"
#   target_table {
#     catalog_id    = var.chatbot_catalog_id            # Replace with the AWS account ID where the original table resides
#     database_name = var.chatbot_source_database_name  # The original Glue database name in the other account
#     name          = var.chatbot_source_table_names[1] # The original table name in the shared Glue database
#   }
# }
# resource "aws_glue_catalog_table" "shared_einstein_connect" {
#   name          = var.chatbot_source_table_names[2] # Name for the resource link table
#   database_name = aws_glue_catalog_database.glue_data_catalog_customer_connectchatbot.name
#   lifecycle {
#     ignore_changes = all
#   }
#   table_type = "LINK"
#   target_table {
#     catalog_id    = var.chatbot_catalog_id            # Replace with the AWS account ID where the original table resides
#     database_name = var.chatbot_source_database_name  # The original Glue database name in the other account
#     name          = var.chatbot_source_table_names[2] # The original table name in the shared Glue database
#   }
# }