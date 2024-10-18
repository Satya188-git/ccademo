import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "ivr_combined_2509data_ext_table"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
QueryString = f"""CREATE OR REPLACE VIEW \"{view_name}\" AS (
   select *,
    CASE
        WHEN l3_tag IN (
            'Abandoned - Self Service Attempt',
            'Abandoned - Self Service No Attempt',
            'Contained - Self Served - IVR',
            'Contained - System - External Transfer'
        ) THEN 'Contained'
        WHEN l3_tag IN (
            'Transfer - System - Agent',
            'Transfer - System - Exception',
            'Transfer - User - Self Service Attempt - Success',
            'Transfer - User - Self Service Attempt w/o Success'
        ) THEN 'TRANSFER' ELSE 'Uncategorised'
    END AS l1_tag,
    CASE
        WHEN l3_tag IN (
            'Contained - Self Served - IVR',
            'Contained - System - External Transfer'
        ) THEN 'Contained- Self Served'
        WHEN l3_tag IN (
            'Abandoned - Self Service Attempt',
            'Abandoned - Self Service No Attempt'
        ) THEN 'Contained- Abandoned'
        WHEN l3_tag IN (
            'Transfer - System - Agent',
            'Transfer - System - Exception'
        ) THEN 'Transfer- System'
        WHEN l3_tag IN (
            'Transfer - User - Self Service Attempt - Success',
            'Transfer - User - Self Service Attempt w/o Success'
        ) THEN 'Transfer- User' ELSE 'Uncategorised'
    END AS l2_tag
FROM (
        SELECT ctr.contact_id,
            csr.is_queued,
            date_format(ctr.initiation_timestamp, '%m/%d/%Y %h:%i:%s %p') AS call_start_date_time,
            date_format(ctr.initiation_timestamp, '%Y-%m-%d') AS call_start_date_time_hours,
            'ssb_pl' as self_service_block,
            lower(trim(split_part(REVERSE(split_part(REVERSE(TRIM(attributes['module_journey'])), '|', 1)),'>',1))) AS module_where_call_ended,
            'ssc_pl' as self_service_count,
            ROUND((to_unixtime(ctr.disconnect_timestamp) - to_unixtime(ctr.connected_to_system_timestamp)) / 60,1) AS call_duration_minute,
            lower(trim(split_part(REVERSE(split_part(REVERSE(TRIM(attributes['customer_journey'])), '|', 1)),'>',1))) as call_end_destination,
            ctr.attributes [ 'customer_type' ] as customer_type,
            ctr.attributes [ 'contract_account' ] as contract_account,
            ctr.attributes [ 'supplied_phone_number' ] as supplied_phone_number,
            ctr.disconnect_reason as call_end_reason,
            ctr.customer_endpoint_address as caller_phone_number,
            date_format(ctr.initiation_timestamp, '%W') AS day_of_week,
            ctr.attributes['customer_journey'] as customer_journey,
            ctr.attributes['module_journey'] as module_journey,
            ctr.attributes['intent_journey'] as intent_journey,
            CASE
                WHEN EXTRACT(
                    DOW
                    FROM ctr.initiation_timestamp
                ) IN (6, 7) THEN 'Weekend' ELSE 'Weekday'
            END AS weekday_check,
            DATE(ctr.initiation_timestamp) as date,
                
            -- Abandoned and Transfer logic here...
            CASE
                WHEN lower(ctr.attributes [ 'self_service_attempt' ]) = 'true'
                and (
                    csr.is_queued IS NULL
                    OR csr.is_queued = 0
                )
                and lower(ctr.attributes [ 'self_service_success' ]) = 'false'
                THEN 'Abandoned - Self Service Attempt'
                -- Continue case logic for l3_tag...
            END AS l3_tag,
            ctr.attributes
   FROM \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\" as ctr
    inner join \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_statistic_record\" as csr on ctr.contact_id = csr.contact_id
   where upper(ctr.channel) = 'VOICE' and upper(ctr.initiation_method) = 'INBOUND'
   and date_format(initiation_timestamp, '%Y-%m-%d') >= '2024-09-25'));""",
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