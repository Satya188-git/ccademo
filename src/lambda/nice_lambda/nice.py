import json
import requests
import awswrangler as wr
import boto3
import pandas as pd

import boto3
from botocore.exceptions import ClientError
 
 
def get_secret(secret_api_key):
    secret_name = "dev/ccc-analytics/nice"
    region_name = "us-west-2"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )

        # Check if the secret is in SecretString or binary format
        if 'SecretString' in get_secret_value_response:
            secret = get_secret_value_response['SecretString']
        else:
            secret = base64.b64decode(get_secret_value_response['SecretBinary'])
        
        # Parse the secret string (JSON format)
        secret_dict = json.loads(secret)

        # Access the specific key 'nice_common_api_key'
        api_key = secret_dict.get(secret_api_key, None)
        
        if api_key:
            print(f"API Key: got api key")
        else:
            print("Key 'nice_common_api_key' not found in secret.")
        
        return api_key

    except ClientError as e:
        # Handle the exception
        print(f"Error: {e}")
        raise e
def call_api(url):
    payload = {}
    headers = {}

    try:
        response = requests.request("GET", url, headers=headers, data=payload)
        response.raise_for_status()
        data = response.json()
        
        return data
        
    except requests.exceptions.RequestException as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"An error occurred while fetching data: {e}")
        }

        
        
    
def save_to_s3(data,name,folder):
    # Convert JSON data to a DataFrame using AWS Wrangler
        df = pd.DataFrame(data)
        
        # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
        wr.s3.to_parquet(
            df=df,
            path="s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/"+folder+"/nice_sample_"+name+".parquet",
            index=False
        )
        
        

def lambda_handler(event, context):
    secret_api_key = 'nice_common_api_key'
    api_key = get_secret(secret_api_key)
    secret_api_key = 'nice_hist_queuestats_key'
    api_key_questats = get_secret(secret_api_key)
    #Situational Awareness Dashboard
    try:
       
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/R_Entity.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/QUEUESTATS.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Date.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Schedule.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/PLAN.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        #YearToDate WFM Dashboard
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/YTD_Entity.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com/query/YTD_Queuestats.json?apikey={api_key_questats}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/YTD_Date.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/YTD_Schedule.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/YTD_Plan.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        #Historical WFM Dashboard
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Hist_Entity.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com/query/Hist_Queuestats.json?apikey={api_key_questats}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Hist_Date.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Hist_Schedule.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
        url = f"https://sdge-nde.nicecloudsvc.com:443/query/Hist_Plan.json?apikey={api_key}"
        data = call_api(url)
        save_to_s3(data,url.split("/")[-1].split(".")[0],url.split("/")[-1].split(".")[0])
        
    # payload = {}
    # headers = {}

    # try:
    #     response = requests.request("GET", url1, headers=headers, data=payload)
    #     response.raise_for_status()

    #     data1 = response.json()
        
    #     response = requests.request("GET", url2, headers=headers, data=payload)
    #     response.raise_for_status()

    #     data2 = response.json()
        
    #     response = requests.request("GET", url3, headers=headers, data=payload)
    #     response.raise_for_status()

    #     data3 = response.json()
        
    #     response = requests.request("GET", url4, headers=headers, data=payload)
    #     response.raise_for_status()

    #     data4 = response.json()

    #     # Convert JSON data to a DataFrame using AWS Wrangler
    #     df1 = pd.DataFrame(data1)
    #     df2 = pd.DataFrame(data2)
    #     df3 = pd.DataFrame(data3)
    #     df4 = pd.DataFrame(data4)

    #     # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
    #     wr.s3.to_parquet(
    #         df=df1,
    #         path='s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/nice_sample_YTD_Queuestats.parquet',
    #         index=False
    #     )
        
    #     # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
    #     wr.s3.to_parquet(
    #         df=df2,
    #         path='s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/nice_sample_YTD_Entity.parquet',
    #         index=False
    #     )
        
    #     # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
    #     wr.s3.to_parquet(
    #         df=df3,
    #         path='s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/nice_sample_YTD_Schedule.parquet',
    #         index=False
    #     )
        
    #     # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
    #     wr.s3.to_parquet(
    #         df=df4,
    #         path='s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/nice_sample_YTD_Plan.parquet',
    #         index=False
    #     )
        
        # Save the DataFrame to a Parquet file in S3 using AWS Wrangler
        # wr.s3.to_parquet(
        #     df=df,
        #     path='s3://sdge-dcctr-dev-wus2-s3-nice-sample-data/nice_sample_op.parquet',
        #     index=False
        # )

        return {
            'statusCode': 200,
            'body': json.dumps('Data saved to S3 successfully!')
        }

    

    except ValueError as ve:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing JSON data: {ve}")
        }

    except Exception as ex:
        return {
            'statusCode': 500,
            'body': json.dumps(f"An unexpected error occurred: {ex}")
        }
