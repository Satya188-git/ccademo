import boto3
import time
import sys
client = boto3.client('athena')
 
# Reading the command line arguments for env and view name
# Skip the first argument as its the script name
args = sys.argv[1:]
env = args[0]
 
# The view name that needs to be created
view_name = "ivr_call_transactions"
 
print("env : ", env)
print("View to be created :", view_name)
 
print("Executing the view: ")
start_query_response = client.start_query_execution(
QueryString = f"""CREATE OR REPLACE VIEW {view_name} AS 
    (SELECT t1.*,
    	t2.event_sequence,
    	t2.module_journey_part,
    	t2.module_name,
    	t2.transaction_reason,
    	t2.transaction_result,
    	t2.total_transactions,
    	t2.ss_transaction,
    	split_part
    	(
    	(max(CASE WHEN t2.ss_transaction = 'y' THEN concat(CAST(t2.event_sequence AS VARCHAR),'_',	t2.transaction_reason) END)
    	OVER 
    	(
    	PARTITION BY t1.contact_id
    	ORDER BY t2.ssb_check 
    	ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    	)
    	), '_',	2
    	) AS self_service_block,
    	ROW_NUMBER() OVER () AS t1_rn
    FROM (
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
    					'Transfer - User - Self Service Attempt w/o Success',
    					'Transfer - User - Skipped IVR'
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
    					'Transfer - User - Self Service Attempt w/o Success',
    					'Transfer - User - Skipped IVR'
    				) THEN 'Transfer- User' ELSE 'Uncategorised'
    			END AS l2_tag
    		FROM (
    				SELECT ctr.contact_id,
    					csr.is_queued,
    					ctr.initiation_timestamp AS call_start_date_time,
    					date_trunc('second',CAST(ctr.initiation_timestamp AS timestamp)) AS call_start_date_time_hours,
    					lower(trim(split_part(REVERSE(split_part(REVERSE(TRIM(attributes [ 'module_journey' ])),'|',1)),'>',1))) AS module_where_call_ended,
    					'ssc_pl' as self_service_count,
    					ROUND((to_unixtime(ctr.disconnect_timestamp) - to_unixtime(ctr.connected_to_system_timestamp)) / 60,1) AS call_duration_minute,
    					lower(trim(split_part(REVERSE(split_part(REVERSE(TRIM(attributes [ 'customer_journey' ])),'|',1)),'>',1))) as call_end_destination,
    					ctr.attributes [ 'customer_type' ] as customer_type,
    					ctr.attributes [ 'contract_account' ] as contract_account,
    					ctr.attributes [ 'supplied_phone_number' ] as supplied_phone_number,
    					ctr.disconnect_reason as call_end_reason,
    					ctr.customer_endpoint_address as caller_phone_number,
    					case 
    					when lower(ctr.attributes ['customer_type']) like '%cca%' 
    					then 'Yes' else 'No'
    					end as CCA,
    					date_format(ctr.initiation_timestamp, '%W') AS day_of_week,
    					ctr.attributes [ 'customer_journey' ] as customer_journey,
    					ctr.attributes [ 'module_journey' ] as module_journey,
    					ctr.attributes [ 'intent_journey' ] as intent_journey,
    					CASE
    						WHEN EXTRACT(
    							DOW
    							FROM ctr.initiation_timestamp
    						) IN (6, 7) THEN 'Weekend' ELSE 'Weekday'
    					END AS weekday_check,
    					DATE(ctr.initiation_timestamp) as date,
    
    					--Abandoned - Self Service Attempt
    
    					CASE
    						WHEN lower(ctr.attributes [ 'self_service_attempt' ]) = 'true'
    						and (
    							csr.is_queued IS NULL
    							OR csr.is_queued = 0
    						)
    						and lower(ctr.attributes [ 'self_service_success' ]) = 'false' THEN 'Abandoned - Self Service Attempt' 
    
    						-- Abandoned - Self Service No Attempt
    
    						WHEN lower(ctr.attributes [ 'self_service_attempt' ]) = 'false'
    						and (
    							csr.is_queued IS NULL
    							OR csr.is_queued = 0
    						)
    						and (
    							lower(
    								ctr.attributes [ 'external_transfer_destination' ]
    							) = 'none'
    							OR lower(
    								ctr.attributes [ 'external_transfer_destination' ]
    							) IS NULL
    						) THEN 'Abandoned - Self Service No Attempt' 
    
    						--Contained - Self Served - IVR
    
    						WHEN lower(ctr.attributes [ 'self_service_success' ]) = 'true'
    						and (
    							csr.is_queued IS NULL
    							OR csr.is_queued = 0
    						) THEN 'Contained - Self Served - IVR' 
    
    						--Contained - System - External Transfer
    
    						WHEN lower(ctr.attributes [ 'external_transfer_destination' ]) IN ('billmatrix', 'legacy') 
    						THEN 'Contained - System - External Transfer' 
    
    						--Transfer - System - Agent
    
    						WHEN lower(ctr.attributes [ 'transfer_reason' ]) = 'system_agent_transfer'
    						and csr.is_queued = 1 THEN 'Transfer - System - Agent' 
    
    						--Transfer - System - Exception
    
    						WHEN lower(ctr.attributes [ 'transfer_reason' ]) = 'exception'
    						and csr.is_queued = 1 THEN 'Transfer - System - Exception' 
    
    						--Transfer - User - Self Service Attempt - Success
    
    						WHEN lower(ctr.attributes [ 'transfer_reason' ]) = 'user_agent_request'
    						and lower(ctr.attributes [ 'self_service_success' ]) = 'true' THEN 'Transfer - User - Self Service Attempt - Success' 
    
    						--Transfer - User - Self Service Attempt - wo Success
    
    						WHEN lower(ctr.attributes [ 'transfer_reason' ]) = 'user_agent_request'
    						and lower(ctr.attributes [ 'self_service_attempt' ]) = 'true'
    						and lower(ctr.attributes [ 'self_service_success' ]) = 'false' THEN 'Transfer - User - Self Service Attempt w/o Success' 
    
    						--Transfer - User - Skipped IVR
    
    						WHEN lower(ctr.attributes [ 'transfer_reason' ]) = 'user_agent_request'
    						and lower(ctr.attributes [ 'self_service_attempt' ]) = 'false' THEN 'Transfer - User - Skipped IVR' ELSE 'Uncategorised'
    					END AS l3_tag,
    					ctr.attributes
    				FROM \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\" as ctr
    					inner join \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_statistic_record\" as csr on ctr.contact_id = csr.contact_id
    				where upper(ctr.channel) = 'VOICE'
    					and upper(ctr.initiation_method) = 'INBOUND'
    					and date_format(initiation_timestamp, '%Y-%m-%d') >= '2024-09-25'
    			)
    	) t1
    LEFT JOIN 
    (
    SELECT *,
    ROW_NUMBER() OVER 
    (
    PARTITION BY contact_id,	
    CASE WHEN ss_transaction = 'y' 
    THEN 'cat1' --ss
    WHEN ss_transaction = 'n'
    THEN 'cat2' --not ss
    ELSE 'cat3' -- trans_butnot_sstrans
    END
    ORDER BY event_sequence
    ) AS ssb_check
    FROM 
    (
    SELECT *,
    CASE
    --accountbalance
    WHEN TRIM(module_name) = 'accountbalance'
    and TRIM(transaction_reason) = 'fetchbalanceamt'
    and TRIM(transaction_result) in ('success', 'failed') THEN 'n'
    WHEN module_name = 'accountbalance'
    and transaction_reason = 'customerheardbalance'
    and transaction_result in ('success') THEN 'y' 
    
    -- authentication
    WHEN TRIM(module_name) = 'authentication' THEN 'n' 
    
    -- billcopy
    
    WHEN TRIM(module_name) = 'billcopy'
    and TRIM(transaction_reason) = 'fetchbillcopy'
    and TRIM(transaction_result) in ('success', 'failed') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'billcopy'
    and TRIM(transaction_reason) = 'processbillcopyrequest'
    and TRIM(transaction_result) in ('success') 
    THEN 'y'
    
    WHEN TRIM(module_name) = 'billcopy'
    and TRIM(transaction_reason) = 'processbillcopyrequest'
    and TRIM(transaction_result) in ('failed') 
    THEN 'n' 
    
    -- billmatrix
    WHEN TRIM(module_name) = 'billmatrix'
    and TRIM(transaction_reason) = 'transfertobillmatrix'
    and TRIM(transaction_result) in ('success') 
    THEN 'y' 
    
    -- billpayoptions
    
    WHEN TRIM(module_name) = 'billpayoptions'
    and TRIM(transaction_reason) in ('fetchcustomerenrolledstatus','getaccountbalanceinfo')
    and TRIM(transaction_result) in ('success', 'failed') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'billpayoptions'
    and TRIM(transaction_reason) in ('customerheardbalance')
    and TRIM(transaction_result) in ('success') THEN 'y' 
    
    -- mailingaddress
    
    WHEN TRIM(module_name) = 'mailingaddress'
    and TRIM(transaction_reason) in ('customerheardbalance','customerheardmailingaddress')
    and TRIM(transaction_result) in ('success') 
    THEN 'y' 
    
    -- outage
    
    WHEN TRIM(module_name) = 'outage'
    and TRIM(transaction_reason) in ('serviceorderservice',	'createoutagereport','dateoutageest','timeoutageest')
    and TRIM(transaction_result) in ('success') 
    THEN 'y'
    
    WHEN TRIM(module_name) = 'outage'
    and TRIM(transaction_reason) in (
    							'serviceorderservice',
    							'createoutagereport',
    							'dateoutageest',
    							'timeoutageest'
    						)
    and TRIM(transaction_result) in ('failed') 
    THEN 'n' 
    
    -- paymentarrangement
    
    WHEN TRIM(module_name) = 'paymentarrangement'
    						and TRIM(transaction_reason) in (
    							'checkpaymentarrangementeligibility',
    							'getpaymentarrangementdetails'
    						)
    and TRIM(transaction_result) in ('success', 'failed') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'paymentarrangement'
    and TRIM(transaction_reason) in ('createpaymentarrangement', 'paymentagreement')
    and TRIM(transaction_result) in ('failed') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'paymentarrangement'
    and TRIM(transaction_reason) in ('createpaymentarrangement',
    							'customerheardbalance'
    						)
    and TRIM(transaction_result) in ('success') THEN 'y' 
    
    -- payoverphone
    
    WHEN TRIM(module_name) = 'payoverphone'
    and TRIM(transaction_reason) in ('customerheardbalance')
    and TRIM(transaction_result) in ('success') 
    THEN 'y'
    
    WHEN TRIM(module_name) = 'payoverphone'
    and TRIM(transaction_reason) in (
    							'getaccountbalanceinfo',
    							'paymentprocessrequest',
    							'fetchpbpenrolledstatus'
    						)
    and TRIM(transaction_result) in ('success', 'failed') -- look for the condition in yellow strip
    THEN 'n' 
    
    -- predictive
    
    WHEN TRIM(module_name) = 'predictive'
    and TRIM(transaction_reason) in ('predictiveapi')
    and TRIM(transaction_result) in ('success', 'failed') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'predictive'
    and TRIM(transaction_reason) 
    in ('fetchcustomerinfopredictiveapi','customerheardoutageinformation') --fetchcustomerinfopredictiveapi this was for test
    and TRIM(transaction_result) in ('success') 
    THEN 'y' 
    
    -- solar/ev
    WHEN TRIM(module_name) = 'solar/ev'
    and TRIM(transaction_reason) in (
    							'customerheardtypeofev',
    							'customerheardevincentives',
    							'customerheardevchargingstation',
    							'customerheardbestevplan',
    							'customerheardsolarbill',
    							'customerheardnembill',
    							'customerheardsbpnonccaresidential',
    							'customerheardsbpnonccabusiness',
    							'customerheardsbpccaresidential',
    							'customerheardsbpccabusiness',
    							'customerheardnempricingplan'
    						)
    and TRIM(transaction_result) in ('success') 
    THEN 'y'
    
    WHEN TRIM(module_name) = 'solar/ev'
    and TRIM(transaction_reason) in ('getcustomertypesolar/ev', 'cca')
    and TRIM(transaction_result) in ('yes', 'no') 
    THEN 'n'
    
    WHEN TRIM(module_name) = 'solar/ev'
    and TRIM(transaction_reason) in (
    							'customerheardtypeofev',
    							'customerheardevincentives',
    							'customerheardevchargingstation',
    							'customerheardbestevplan',
    							'customerheardsolarbill',
    							'customerheardnembill',
    							'customerheardsbpnonccaresidential',
    							'customerheardsbpnonccabusiness',
    							'customerheardsbpccaresidential',
    							'customerheardsbpccabusiness',
    							'customerheardnempricingplan'
    						)
    and TRIM(transaction_result) in ('failed') THEN 'n' 
    
    -- stopservice
    WHEN TRIM(module_name) = 'stopservice'
    and TRIM(transaction_reason) in ('createstopserviceorder')
    and TRIM(transaction_result) in ('success') 
    THEN 'y'
    
    WHEN TRIM(module_name) = 'stopservice'
    and TRIM(transaction_reason) not in ('createstopserviceorder') 
    THEN 'n' 
    
    ELSE 'NA'
    
    END AS ss_transaction
    
    FROM (
    						SELECT contact_id,
    							mj as module_journey,
    							total_transactions,
    							ROW_NUMBER() OVER (PARTITION BY contact_id) -1 AS event_sequence,
    							TRIM(journey_step) AS module_journey_part,
    							lower(split_part(TRIM(journey_step), '>', 1)) AS module_name,
    							lower(split_part(TRIM(journey_step), '>', 2)) AS transaction_reason,
    							CASE
    								WHEN length(TRIM(journey_step)) - length(regexp_replace(TRIM(journey_step), '>', '')) >= 2 THEN lower(
    									regexp_replace(TRIM(journey_step), '^[^>]*>[^>]*>', '')
    								) -- Handles cases with two or more '>' 
    								ELSE NULL -- Handles cases with less than two '>'
    							END AS transaction_result
    						FROM (
    								SELECT contact_id,
    									mj,
    									split(mj, '|') AS journey_steps,
    									LENGTH(mj) - LENGTH(REPLACE(mj, '|', '')) AS total_transactions -- added this on 211024
    								FROM (
    										SELECT contact_id,
    											attributes [ 'module_journey' ] as mj
    										FROM \"sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-link\".\"contact_record\" as ctr
    										where upper(ctr.channel) = 'VOICE'
    											and upper(ctr.initiation_method) = 'INBOUND'
    											and date_format(initiation_timestamp, '%Y-%m-%d') >= '2024-09-25'
    									)
    							)
    							CROSS JOIN UNNEST(journey_steps) AS t (journey_step)
    					)
    			)
    		order by contact_id,
    			event_sequence,
    			module_name,
    			transaction_reason
    	) t2 on t1.contact_id = t2.contact_id
    ORDER BY t1.call_start_date_time_hours desc,
    	t1.contact_id,
    	t2.event_sequence;""",
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