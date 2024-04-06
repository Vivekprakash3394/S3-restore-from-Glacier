import boto3
from boto3.session import Session
ACCESS_KEY_ID = 'AKIA3************'
SECRET_KEY = 'Zfm5S***********************************'
client = boto3.client('s3',aws_access_key_id=ACCESS_KEY_ID, aws_secret_access_key=SECRET_KEY)
session = Session(aws_access_key_id=ACCESS_KEY_ID, aws_secret_access_key=SECRET_KEY) 
s3 = session.resource('s3')
bucket = 'prod-snapshots'
my_bucket = s3.Bucket(bucket)
for s3_files in my_bucket.objects.filter(Prefix = "prod/prod-data-july-s3/fes/public.activity_logs_6_2022/"):
    if (s3_files.key.endswith('.parquet')):
        print(s3_files.key)
        try:
            response = client.restore_object(
                Bucket='prod-snapshots',
                Key=s3_files.key,
                RestoreRequest={
                    'Days': 7,
                    'GlacierJobParameters': {
                    'Tier': 'Standard',
                    },
                },
            )
            with open('status.txt','a') as f:
                f.write(s3_files.key)
                f.write(str(response))
                f.write('\n')
            print(response)
        except Exception as e:
            print(str(e))
