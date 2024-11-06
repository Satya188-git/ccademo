import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "fcr_data_view"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
    QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS (
        SELECT
            customer_endpoint_address,
            a.contact_id,
            queue_enqueue_timestamp,
            agent_username,
            queue_name AS requested_call_type,
            CASE 
                WHEN (actual_call_type IS NULL) THEN queue_name 
                ELSE actual_call_type 
            END AS actual_call_type,
            date_parse(substr(CAST(initiation_timestamp AS varchar), 1, 19), '%Y-%m-%d %H:%i:%s') AS initiation_timestamp_original,
            date_parse(substr(CAST(date_add('second', (-(agent_interaction_duration_ms) / 1000), disconnect_timestamp) AS varchar), 1, 19), '%Y-%m-%d %H:%i:%s') AS initiation_timestamp,
            date_parse(substr(CAST(disconnect_timestamp AS varchar), 1, 19), '%Y-%m-%d %H:%i:%s') AS disconnect_timestamp,
            CASE 
                WHEN (
                    LEAD(date_add('second', (-(agent_interaction_duration_ms) / 1000), disconnect_timestamp)) OVER (
                        PARTITION BY customer_endpoint_address, queue_name 
                        ORDER BY date_add('second', (-(agent_interaction_duration_ms) / 1000), disconnect_timestamp) ASC
                    ) IS NULL
                ) THEN 9999999999 
                ELSE date_diff('second', disconnect_timestamp, LEAD(date_add('second', (-(agent_interaction_duration_ms) / 1000), disconnect_timestamp)) OVER (
                    PARTITION BY customer_endpoint_address, queue_name 
                    ORDER BY date_add('second', (-(agent_interaction_duration_ms) / 1000), disconnect_timestamp) ASC
                )) 
            END AS time_difference_seconds,
            substr(CAST(initiation_timestamp AS varchar), 1, 4) AS year
        FROM 
            \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\" a
        LEFT JOIN (
            SELECT contact_id, actual_call_type
            FROM (
                SELECT initial_contact_id as contact_id, queue_name as actual_call_type,
                    RANK() OVER (PARTITION BY initial_contact_id ORDER BY disconnect_timestamp DESC) AS rank
                FROM \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\"
                WHERE initial_contact_id IS NOT NULL
            ) 
            WHERE rank = 1
        ) b 
        ON a.contact_id = b.contact_id
        WHERE 
            queue_name IS NOT NULL 
            AND date(initiation_timestamp) >= date('2024-01-01') 
            AND agent_interaction_duration_ms > 0
    );""",
    QueryExecutionContext={
        'Database': f"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views",
        'Catalog': 'awsdatacatalog'
    },
    ResultConfiguration={
        'OutputLocation': f's3://sdge-dcctr-{env}-wus2-s3-ccc-analytics-athena-results/athena_views/',
    },
    WorkGroup='primary'
)

 
print(f"The status of the execution using API call is : {start_query_response['ResponseMetadata']['HTTPStatusCode']}")
print(f"The execution id is : {start_query_response['QueryExecutionId']}")
 
if start_query_response['QueryExecutionId'] !='':
 query_status = client.get_query_execution(
   QueryExecutionId = start_query_response['QueryExecutionId']
  )
 print(f"The api response code for query execution is : {query_status['ResponseMetadata']['HTTPStatusCode']}")
 print(f"The status of query execution is : {query_status['QueryExecution']['Status']['State']}")
 while ((query_status['QueryExecution']['Status']['State'] == 'QUEUED') or (query_status['QueryExecution']['Status']['State'] == 'RUNNING')):
  time.sleep(5)
  query_status = client.get_query_execution(
     QueryExecutionId = start_query_response['QueryExecutionId']
    )
  print(f"The latest status of query execution is : {query_status['QueryExecution']['Status']['State']}")
else:
 print("The query is not submitted!. Please check the issue")