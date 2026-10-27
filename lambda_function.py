import json
import boto3
import urllib.parse
import uuid

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('S3MetadataTable')

def lambda_handler(event, context):
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    file_size = event['Records'][0]['s3']['object'].get('size', 0)
    
    print(f"Processing file: {key} from bucket: {bucket}")
    
    # Write metadata into DynamoDB
    try:
        table.put_item(
            Item={
                'FileId': str(uuid.uuid4()),
                'BucketName': bucket,
                'FileName': key,
                'FileSize': file_size
            }
        )
        print("Successfully logged metadata to DynamoDB!")
    except Exception as e:
        print(f"Error saving to DynamoDB: {e}")
        raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Successfully processed S3 event!')
    }