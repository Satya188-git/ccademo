import boto3
import time
import sys

client = boto3.client('athena')

# Reading command line arguments for environment
args = sys.argv[1:]
env = args[0]

# The view name to be created
view_name = "sdge-chatbot-view"

print("Environment:", env)
print("View to be created:", view_name)

# Athena query string
query_string = f"""
    CREATE OR REPLACE VIEW "{view_name}" AS 
    SELECT s.*, 
        cla.sentiment_overall_score_agent, 
        cla.sentiment_overall_score_customer, 
        cla.sentiment_interaction_score_customer_with_agent 
    FROM (
        WITH
        CTR_TBL AS (
            SELECT
                contact_id,
                date_format(initiation_timestamp, '%m/%d/%Y %h:%i:%s %p') AS chat_start_date_time,
                date_format(disconnect_timestamp, '%m/%d/%Y %h:%i:%s %p') AS chat_end_date_time,
                (to_unixtime(disconnect_timestamp) - to_unixtime(initiation_timestamp)) AS contact_duration_time_sec,
                disconnect_reason AS chat_end_reason,
                queue_name,
                queue_duration_ms * 0.001 AS queue_duration,
                agent_interaction_duration_ms * 0.001 AS agent_interaction_duration,
                agent_customer_hold_duration_ms * 0.001 AS agent_customer_hold_duration,
                agent_after_contact_work_duration_ms * 0.001 AS agent_after_contact_work_duration,
                attributes['ResponseCode'] AS ResponseCode,
                attributes['chatbotTriggerEvent'] AS Chatbot,
                attributes['Chatbot_LastIntent'] AS Chatbot_LastIntent,
                attributes['BusinessType'] AS BusinessType,
                attributes['Intent'] AS Intent
            FROM "sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link"."contact_record"
            WHERE channel = 'CHAT' AND initiation_method = 'API'
        ),

        CALC_TBL AS (
            SELECT ctr.*, 
                (agent_interaction_duration + 
                agent_customer_hold_duration + 
                agent_after_contact_work_duration) AS agent_chat_aht,
                contact_duration_time_sec - 
                (queue_duration +
                agent_interaction_duration + 
                agent_customer_hold_duration + 
                agent_after_contact_work_duration) AS chatbot_duration
            FROM CTR_TBL AS ctr
        ),

        STATUS_TBL AS (
            SELECT c.*, 
                csr.is_connected, 
                csr.is_queued, 
                csr.is_handled, 
                csr.is_abandoned, 
                csr.is_agent_hung_up_first
            FROM CALC_TBL c
            INNER JOIN "sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link"."contact_statistic_record" AS csr
            ON (c.contact_id = csr.contact_id)
        )
    ) AS s
    INNER JOIN "sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link"."contact_lens_conversational_analytics" AS cla
    ON (s.contact_id = cla.contact_id);
"""

# Executing the Athena query
try:
    start_query_response = client.start_query_execution(
        QueryString=query_string,
        QueryExecutionContext={
            'Database': f"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views",
            'Catalog': 'awsdatacatalog'
        },
        ResultConfiguration={
            'OutputLocation': f's3://sdge-dcctr-{env}-wus2-s3-ccc-analytics-athena-results/athena_views/',
        },
        WorkGroup='primary'
    )

    query_execution_id = start_query_response['QueryExecutionId']
    print(f"The query was submitted successfully. Execution ID: {query_execution_id}")

    # Polling for query status
    while True:
        query_status = client.get_query_execution(QueryExecutionId=query_execution_id)
        status = query_status['QueryExecution']['Status']['State']

        if status in ['SUCCEEDED', 'FAILED', 'CANCELLED']:
            break

        print(f"Current status: {status}. Waiting for completion...")
        time.sleep(5)

    # Final status check
    if status == 'SUCCEEDED':
        print("Query succeeded.")
    else:
        reason = query_status['QueryExecution']['Status'].get('StateChangeReason', 'No reason provided.')
        print(f"Query failed with status: {status}. Reason: {reason}")

except Exception as e:
    print(f"An error occurred: {str(e)}")
