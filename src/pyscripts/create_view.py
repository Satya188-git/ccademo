import boto3
import time
import sys
client = boto3.client('athena')

# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
view_name = args[1]

print("env : ", env)
print("View to be created :", view_name)

print("Executing the view: ")
start_query_response = client.start_query_execution(
    QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS ( select *,
	CASE
		WHEN l3_tag IN (
			'Abandoned - Self Service Attempt',
			'Abandoned - Self Service No Attempt',
			'Contained - Self Served - IVR',
			'Contained - System - External Transfer'
		) THEN 'Contained' ELSE 'TRANSFER'
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
			' Transfer - System - Exception'
		) THEN 'Transfer- System'
		WHEN l3_tag IN (
			'Transfer - User - Self Service Attempt - Success',
			'Transfer - User - Self Service Attempt w/o Success'
		) THEN 'Transfer- User' ELSE 'NA'
	END AS l2_tag
	FROM (
		SELECT ctr.contact_id,
			ctr.channel,
			ctr.initiation_method,
			csr.is_queued,
			ctr.attributes,
			date_format(initiation_timestamp, '%m/%d/%Y %h:%i:%s %p') AS call_start_date_time,
			ctr.disconnect_reason as call_end_reason,
			ctr.customer_endpoint_address as caller_phone_number,
			date_format(ctr.initiation_timestamp, '%W') AS day_of_week,
			CASE
				WHEN EXTRACT(
					DOW
					FROM ctr.initiation_timestamp
				) IN (6, 7) THEN 'Weekend' ELSE 'Weekday'
			END AS weekday_check,
			DATE(ctr.initiation_timestamp) as date,
			ctr.attributes [ 'CurtailmentisActive' ] as curtailmentflag,
			--CurtailmentisActive in place of  self_service_attempt attribute for Abandoned - Self Service Attempt
			CASE
				WHEN ctr.attributes [ 'self_service_attempt' ] = 'true'
				and (
					csr.is_queued IS NULL
					OR csr.is_queued = 0
				) THEN 'Abandoned - Self Service Attempt'
				WHEN ctr.attributes [ 'self_service_attempt' ] = 'false'
				and (
					csr.is_queued IS NULL
					OR csr.is_queued = 0
				) THEN 'Abandoned - Self Service No Attempt' 
				--DisasterisActive in place of  self_service_success attribute for Contained - Self Served - IVR
				WHEN ctr.attributes [ 'self_service_success' ] = 'true'
				and (
					csr.is_queued IS NULL
					OR csr.is_queued = 0
				) THEN 'Contained - Self Served - IVR' 
				--language='en' in place of  external_transfer_destination='billmatrix' attribute for Contained - System - External Transfer
				WHEN ctr.attributes [ 'external_transfer_destination' ] = 'billmatrix' THEN 'Contained - System - External Transfer' 
				--CurtailmentisActive in place of  transfer_reason attribute for  Transfer - System - Agent
				WHEN ctr.attributes [ 'transfer_reason' ] = 'system_agent_transfer'
				and csr.is_queued = 1 THEN 'Transfer - System - Agent' 
				--CurtailmentisActive in place of  transfer_reason attribute for  Transfer - System - Exception
				WHEN ctr.attributes [ 'transfer_reason' ] = 'exception'
				and csr.is_queued = 1 THEN 'Transfer - System - Exception' 
				--Mailing address in place of   transfer_reason attribute for Transfer - User - Self Service Attempt - Success
				WHEN ctr.attributes [ 'transfer_reason' ] = 'user_agent_request'
				and ctr.attributes [ 'self_service_success' ] = 'true' THEN 'Transfer - User - Self Service Attempt - Success' 
				--Mailing address in place of   transfer_reason attribute for Transfer - User - Self Service Attempt - wo Success
				WHEN ctr.attributes [ 'transfer_reason' ] = 'user_agent_request'
				and ctr.attributes [ 'self_service_attempt' ] = 'true'
				and ctr.attributes [ 'self_service_success' ] = 'false' THEN '  Transfer - User - Self Service Attempt w/o Success' 
				ELSE 'BLANK'
			END AS l3_tag
		FROM \"sdge-dcctr-{env}-wus2-gdc-ccc-analytics-connect-datalake-link\".\"contact_record\" as ctr
			inner join \"sdge-dcctr-{env}}-wus2-gdc-ccc-analytics-connect-datalake-link\".\"contact_statistic_record\" as csr on ctr.contact_id = csr.contact_id
		where ctr.channel = 'VOICE' and ctr.initiation_method = 'INBOUND'
		and date_format(initiation_timestamp, '%Y-%m-%d') >= '2024-09-25'));""",
	QueryExecutionContext={
        'Database': f"sdge-dcctr-{env}-wus2-gdc-ccc-analytics-connect-datalake-views",
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