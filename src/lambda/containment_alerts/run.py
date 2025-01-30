import os
import json
import boto3
import time
from io import StringIO
import pandas as pd
import numpy as np
 
# Initialize AWS clients
# Athena Client
athena = boto3.client('athena')
# S3 Client
s3 = boto3.client('s3')
# SES Client
ses_client = boto3.client('ses', region_name='us-west-2')

# Get env variable from lambda env vars
env = os.environ['env']

# Athena and S3 configurations
DATABASE = f'sdge-dcctr-{env}-wus2-ccc-analytics-connect-datalake-views'
# S3 Bucket
S3_BUCKET = f'sdge-dcctr-{env}-wus2-s3-ccc-analytics-athena-results'
# S3 Bucket Folder
S3_OUTPUT = f's3://sdge-dcctr-{env}-wus2-s3-ccc-analytics-athena-results/IVR_results/'
 
 
def lambda_handler(event, context):

    def query_execution(column):
        """
        Function to run the Athena Query
        """
        # Step 1: Run the Athena Query
        query = f"""
        SELECT
        {column},
        count(distinct contact_id) AS row_count
        FROM ivr_call_transactions
        GROUP BY {column};
        """
        response = athena.start_query_execution(
            QueryString=query,
            QueryExecutionContext={'Database': DATABASE},
            ResultConfiguration={'OutputLocation': S3_OUTPUT}
        )
        query_execution_id = response['QueryExecutionId']
        print(response)
        # Step 2: Wait for Query to Complete
        status = 'RUNNING'
        while (status == 'RUNNING') or (status == 'QUEUED'):
            response = athena.get_query_execution(QueryExecutionId=query_execution_id)
            status = response['QueryExecution']['Status']['State']
            if status in ['FAILED', 'CANCELLED']:
                raise Exception(f"Query failed or was cancelled: {status}")
            time.sleep(2)  # Poll every 2 seconds
       
        # Retrieve query results from S3
        s3 = boto3.client('s3')
        results_key = f"IVR_results/{query_execution_id}.csv"
        response = s3.get_object(Bucket=S3_BUCKET, Key=results_key)
        results = response['Body'].read().decode('utf-8')
       
        # convert the results into dataframe
        df = pd.read_csv(StringIO(results))
        df['percentage'] = (df['row_count']/sum(df['row_count'])*100).round().astype(int)
 
        df = df.rename(columns={column : 'KPI'})
 
        return df
 
    # Read the CSV results into a Pandas DataFrame
    df_l2 = query_execution("l2_tag")
    df_l3 = query_execution("l3_tag")
   
    # Filter only for required categories
    df_l2 = df_l2[df_l2['KPI'].isin(['Contained - Abandoned', 'Contained - Self Served'])]
    df_l3 = df_l3[df_l3['KPI'].isin(['Transfer - System - Agent', 'Contained - Self Served - IVR'])]
 
    replacements = {'Contained - Abandoned': 'Abandonment Rate', 'Contained - Self Served': 'Self-Service Rate'}
    df_l2['KPI'] = df_l2['KPI'].replace(replacements)
   
    final_df = pd.concat([df_l2, df_l3])
    final_df = final_df.reset_index(drop=True)
 
    # Mapping dictionary for thresholds
    mapping = {'Abandonment Rate': 25, 'Self-Service Rate': 27, 'Transfer - System - Agent': 30, 'Contained - Self Served - IVR': 12}
    mapping_rules = {'Abandonment Rate': "Above", 'Self-Service Rate': "Below", 'Transfer - System - Agent': "Above", 'Contained - Self Served - IVR': "Below"}
 
    # Map the values from the 'Category' column to the new 'Mapped_Value' column
    final_df['Threshold Limit'] = final_df['KPI'].map(mapping)
    final_df['threshold_rules'] = final_df['KPI'].map(mapping_rules)
    final_df['Condition (Is above/below/equal)'] = np.where(final_df['percentage']>final_df['Threshold Limit'],"Above",(np.where(final_df['percentage']<final_df['Threshold Limit'],"Below","Equal")))
    final_df['Threshold violation'] = np.where(final_df['threshold_rules']==final_df['Condition (Is above/below/equal)'],"Yes",np.where(final_df['threshold_rules']=="Equal","At the border","No"))
 
    final_df['percentage'] = final_df['percentage'].astype('str') + "%"
    final_df['Threshold Limit'] = final_df['Threshold Limit'].astype('str') + "%"
 
 
    # Add a timestamp column
    final_df['Timestamp'] = pd.to_datetime('now')
    final_df['Timestamp'] = final_df['Timestamp'].astype("str")
 
    final_df = final_df.rename(columns={'row_count': 'No. of Calls', 'percentage': 'Current Percentage', 'threshold_rules': 'Threshold Rules', 'Threshold violation': 'Threshold Violation'})
 
    final_dict = final_df.to_dict(orient='records')
 
    html_table = final_df.to_html(index=False)  # Convert DataFrame to HTML without the index
 
    # Add CSS to center align the text
    html_table = html_table.replace('<table border="1" class="dataframe">',
                                    '<table border="1" class="dataframe" style="text-align: center; width: 100%;">')
    html_table = html_table.replace('<th>', '<th style="text-align: center;">')  # Center align headers
    html_table = html_table.replace('<td>', '<td style="text-align: center;">')  # Center align cells
 
 
    # Define email content for SES
    
    sender = "ivr-containment-rate-alerts@sdge.com"
    recipients = ["CIVR-CRA@sempra.onmicrosoft.com"]
    subject = f"{env.upper()} : Containment rate Alerts"
    body_html = f"""
    <html>
    <head></head>
    <body>
      Dear All,
     
      Please find the {env.upper()} KPIs' summary report with respect to thresholds:
      <div style="margin-top: 20px;">
      {html_table}
    </body>
    </html>
    """
    # Send the email using SES
    try:
        response = ses_client.send_email(
            Source=sender,
            Destination={
                'ToAddresses': recipients,
            },
            Message={
                'Subject': {
                    'Data': subject,
                },
                'Body': {
                    'Html': {
                        'Data': body_html,
                    }
                }
            }
        )
        return {
            'statusCode': 200,
            'body': f'Email sent successfully!, {json.dumps(final_dict)}'
        }
    except Exception as e: #ClientError
        print(e.response['Error']['Message'])
        return {
            'statusCode': 500,
            'body': 'Failed to send email.'
        }