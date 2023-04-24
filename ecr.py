import boto3

client = boto3.client('ecr')

response = client.create_repository(
    repositoryName='flask-monitoring-app', # Any name of your choice
    tags=[
        {
            'Key': 'flask-app-docker_image', # Any name of your choice
            'Value': 'flask-monitoring-app'  # Any name of your choice
        },
    ],
    imageScanningConfiguration={
        'scanOnPush': True
    }
)

ecr_uri = response['repository']['repositoryUri']
print(f"ECR URI=: {ecr_uri}")
