import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]

# The view name that needs to be created
view_name = "fcr_boxplot_view"
 
# print("env : ", env)
# print("View to be created :", view_name)
 
print("Executing the view: ")

start_query_response = client.start_query_execution(
    QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS 
    SELECT 
    actual_call_type, 
    customer_endpoint_address, 
    COUNT(CASE WHEN time_difference_seconds < 86400 THEN 1 END) AS call_count_24H,
    COUNT(CASE WHEN time_difference_seconds < 604800 THEN 1 END) AS call_count_7D,
    COUNT(CASE WHEN time_difference_seconds < 2592000 THEN 1 END) AS call_count_30D,
    'Last 30 Days' AS date_range
FROM 
    \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views\".\"fcr_data_view\"
WHERE 
    DATE(initiation_timestamp) BETWEEN current_date - interval '30' day AND current_date
GROUP BY 
    actual_call_type, 
    customer_endpoint_address

UNION ALL

SELECT 
    actual_call_type, 
    customer_endpoint_address, 
    COUNT(CASE WHEN time_difference_seconds < 86400 THEN 1 END) AS call_count_24H,
    COUNT(CASE WHEN time_difference_seconds < 604800 THEN 1 END) AS call_count_7D,
    COUNT(CASE WHEN time_difference_seconds < 2592000 THEN 1 END) AS call_count_30D,
    'Last Quarter' AS date_range
FROM 
     \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views\".\"fcr_data_view\"
WHERE DATE(initiation_timestamp) BETWEEN date_trunc('quarter', date_trunc('quarter', current_date) - interval '1' day) AND date_trunc('quarter', current_date) - interval '1' day
GROUP BY 
    actual_call_type, 
    customer_endpoint_address

UNION ALL

SELECT 
    actual_call_type, 
    customer_endpoint_address, 
    COUNT(CASE WHEN time_difference_seconds < 86400 THEN 1 END) AS call_count_24H,
    COUNT(CASE WHEN time_difference_seconds < 604800 THEN 1 END) AS call_count_7D,
    COUNT(CASE WHEN time_difference_seconds < 2592000 THEN 1 END) AS call_count_30D,
    'Year to date' AS date_range
FROM 
     \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views\".\"fcr_data_view\"
WHERE 
    DATE(initiation_timestamp) BETWEEN 
        date_trunc('year', current_date) 
        AND 
        current_date
GROUP BY 
    actual_call_type, 
    customer_endpoint_address;""",
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