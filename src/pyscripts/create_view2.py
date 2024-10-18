import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "sdge-chatbot-view"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS (
            WITH
            CTR_TBL AS(
            SELECT
                contact_id,
                date_format(initiation_timestamp, '%m/%d/%Y %h:%i:%s %p') chat_start_date_time,
                date_format(disconnect_timestamp, '%m/%d/%Y %h:%i:%s %p') chat_end_date_time,
                (to_unixtime(disconnect_timestamp) - to_unixtime(initiation_timestamp)) contact_duration_time_sec,
                disconnect_reason chat_end_reason,
                queue_name,
                queue_duration_ms * 0.001 queue_duration,
                agent_interaction_duration_ms * 0.001 agent_interaction_duration,
                agent_customer_hold_duration_ms * 0.001  agent_customer_hold_duration,
                agent_after_contact_work_duration_ms * 0.001 agent_after_contact_work_duration,
                attributes['ResponseCode'] ResponseCode,
                attributes['chatbotTriggerEvent'] Chatbot,
                attributes['Chatbot_LastIntent'] Chatbot_LastIntent,
                attributes['BusinessType'] BusinessType,
                attributes['Intent'] Intent
			FROM \"sdge-dcctr-{env}-wus2-gdc-ccc-analytics-connect-datalake-link\".\"contact_record\" 
			WHERE channel = 'CHAT' AND initiation_method = 'API'
            ),

            -- Get agent chat AHT and chatbot duration
            CALC_TBL AS(
            SELECT ctr.*,
                (agent_interaction_duration + 
                agent_customer_hold_duration + 
                agent_after_contact_work_duration) agent_chat_aht,
                contact_duration_time_sec - 
                (queue_duration +
                agent_interaction_duration + 
                agent_customer_hold_duration + 
                agent_after_contact_work_duration) chatbot_duration
            FROM CTR_TBL AS ctr
            ),

            -- Get CSR data for each contact record
            STATUS_TBL AS(
            SELECT c.*,
                csr.is_connected,
                csr.is_queued,
                csr.is_handled,
                csr.is_abandoned,
                csr.is_agent_hung_up_first
            FROM CALC_TBL c
            INNER JOIN \"sdge-dcctr-{env}-wus2-gdc-ccc-analytics-connect-datalake-link\".\"contact_statistic_record\" AS csr ON (c.contact_id = csr.contact_id)
            )

            SELECT s.*,
                cla.sentiment_overall_score_agent,
                cla.sentiment_overall_score_customer,
                cla.sentiment_interaction_score_customer_with_agent
            FROM STATUS_TBL s
            INNER JOIN \"sdge-dcctr-{env}-wus2-gdc-ccc-analytics-connect-datalake-link\".\"contact_lens_conversational_analytics\" AS cla ON (s.contact_id = cla.contact_id)
        ));""",
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