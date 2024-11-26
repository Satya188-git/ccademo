import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "ivr_call_events"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS (
    SELECT 
        contact_id,
        initiation_timestamp,
        cj as cutomer_journey,
        ROW_NUMBER() OVER (PARTITION BY contact_id) AS event_sequence_cj,
        TRIM(journey_step) AS event,
        split_part(TRIM(journey_step), '>', 1) AS event_name,
        CASE WHEN 
            split_part(TRIM(journey_step), '>', 2) IS NULL THEN ''
        ELSE split_part(TRIM(journey_step), '>', 2) END AS raw_answer,
        CASE 
            WHEN length(TRIM(journey_step)) - length(regexp_replace(TRIM(journey_step), '>', '')) >= 2
                THEN regexp_replace(TRIM(journey_step), '^[^>]*>[^>]*>', '')  -- Handles cases with two or more '>'
            ELSE NULL  -- Handles cases with less than two '>'
        END AS event_result,
        ROW_NUMBER() OVER () AS t2_rn
    FROM (
        SELECT 
            contact_id,
            initiation_timestamp,
            cj,
            split(cj, '|') AS journey_steps
        FROM 
        (SELECT contact_id, initiation_timestamp, attributes['customer_journey'] as cj  
    	FROM \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\" as ctr
        where upper(ctr.channel) = 'VOICE'
        and upper(ctr.initiation_method) = 'INBOUND'
        and date_format(initiation_timestamp, '%Y-%m-%d') >= '2024-09-25')
    ) CROSS JOIN UNNEST(journey_steps) AS t (journey_step)
    WHERE date(initiation_timestamp) >= date_add('month', -2, current_date)   
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