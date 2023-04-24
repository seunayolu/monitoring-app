import boto3

client = boto3.client('ecr')

response = client.create_repository(
    repositoryName='flask-app-ecr-repo',
    tags=[
        {
            'Key': 'flask-app-images',
            'Value': 'flask-monitoring-app-image'
        },
    ],
    imageScanningConfiguration={
        'scanOnPush': True
    }
)

ecr_uri = response['repository']['repositoryUri']
print(f"ECR URI=: {ecr_uri}")
