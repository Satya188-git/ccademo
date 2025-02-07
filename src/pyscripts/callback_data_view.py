import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "callback_data_view"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
    QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS 
        WITH
  FilteredContacts AS (
   SELECT
     contact_id
   , initial_contact_id
   , previous_contact_id
   , related_contact_id
   , next_contact_id
   , attributes
   , attributes['CallbackOriginalContactID'] CallbackOriginalContactID
   , channel
   , initiation_timestamp
   , CAST(replace(CAST(at_timezone(initiation_timestamp, 'America/Los_Angeles') AS varchar), 'America/Los_Angeles', '') AS timestamp) initiation_timestamp_pst
   , DATE(CAST(replace(CAST(at_timezone(initiation_timestamp, 'America/Los_Angeles') AS varchar), 'America/Los_Angeles', '') AS timestamp)) date_pst
   , last_update_timestamp
   , attributes['CallbackDateTime'] CallbackDateTime
   , lower(attributes['CallbackOffered']) CallbackOffered
   , lower(attributes['CallbackRejected']) CallbackRejected
   , lower(attributes['CallbackConfirmed']) CallbackConfirmed
   , lower(attributes['callbackMade']) callbackMade
   , lower(attributes['CallbackPlaced']) CallbackPlaced
   , lower(attributes['CallbackFailed']) CallbackFailed
   , lower(attributes['CallbackRetryAttempts']) CallbackRetryAttempts
   , attributes['CallbackType'] CallbackType
   , attributes['CallbackQueue'] CallbackQueue
   , attributes['CALLBACKNUMBER'] CALLBACKNUMBER
   , attributes['CallbackPhoneNo'] CallbackPhoneNo
   , initiation_method
   FROM
    \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\"
   WHERE ((channel = 'VOICE') AND (date_format(CAST(replace(CAST(at_timezone(initiation_timestamp, 'America/Los_Angeles') AS varchar), 'America/Los_Angeles', '') AS timestamp), '%Y-%m-%d') >= '2025-01-14'))
) 
, CallbackMatches AS (
   SELECT
     parent.contact_id parent_contact_id
   , parent.CallbackType parent_CallbackType
   , parent.CallbackOriginalContactID parent_CallbackOriginalContactID
   , parent.initial_contact_id parent_initial_contact_id
   , child.contact_id callbackcallID
   , child.callbackplaced callbackcallplacedflag
   , child.initiation_timestamp as callbackcallinitiation_timestamp
   , child.CallbackDateTime as api_cb_is_rescheduled_timestamp -- this timestamp is for the case when 'CB' is rescheduled and there is a new CB time given by the caller
   , child.CallbackOffered as api_cb_offered_check -- this offered check is to see if the CB offered was again present in CB call
   , child.initiation_method as callbackcallinitiation_method -- this will always be API but taking for using in condition
   FROM
     (FilteredContacts parent
   LEFT JOIN FilteredContacts child ON (((parent.CallbackType = 'ASAP') AND (parent.contact_id = child.CallbackOriginalContactID)) OR ((parent.CallbackType = 'Scheduled') AND (parent.contact_id = child.CallbackOriginalContactID))))
   WHERE (child.initiation_method IN ('API', 'CALLBACK'))
) 
SELECT
  fc.*,
  CASE WHEN fc.CallbackConfirmed='true'
  THEN 'Confirmed'
  WHEN fc.CallbackRejected='true'
  THEN 'Rejected'
  ELSE null
  END AS Cnf_Rej_Check
, cm.callbackcallID
, cm.callbackcallplacedflag
, CASE 
  WHEN (callbackcallinitiation_method='API' and api_cb_is_rescheduled_timestamp is not null and api_cb_offered_check='true')
  THEN 1 
  ELSE NULL
  END AS was_callback_again_rescheduled_flag
, CAST(replace(CAST(at_timezone(callbackcallinitiation_timestamp, 'America/Los_Angeles') AS varchar), 'America/Los_Angeles', '') AS timestamp) as callbackcallinitiation_timestamp_pst
FROM
  (FilteredContacts fc
LEFT JOIN CallbackMatches cm ON (fc.contact_id = cm.parent_contact_id))
ORDER BY date(initiation_timestamp_pst) DESC;""",
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