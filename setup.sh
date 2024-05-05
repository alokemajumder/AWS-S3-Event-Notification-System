#!/bin/bash

# Description: This script automates the creation of AWS resources including an IAM role, S3 bucket,
# Lambda function, and an SNS topic with an email subscription. It sets up notifications for any changes
# in the S3 bucket content.
# Author: Aloke Majumder ( https://github.com/alokemajumder )
# Disclaimer: This script is provided "as is", without warranty of any kind, express or implied.
# License: MIT License - Feel free to use and modify, but please retain this disclaimer and license.

# Check for AWS CLI and install if not present
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not installed. Installing..."
    sudo apt update
    sudo apt install -y awscli
    echo "AWS CLI installed."
else
    echo "AWS CLI is already installed."
fi

# Check for zip utility and install if not present
if ! command -v zip &> /dev/null
then
    echo "zip utility not installed. Installing..."
    sudo apt install -y zip
    echo "zip utility installed."
else
    echo "zip utility is already installed."
fi

# Gather user inputs
read -p "Enter your email address for SNS notifications: " EMAIL
read -p "Enter a unique name for your S3 bucket (leave blank to generate one): " BUCKET_NAME
read -p "Enter a name for your Lambda function (leave blank for 'S3ChangeNotificationLambda'): " LAMBDA_NAME

# Set defaults if blank
BUCKET_NAME=${BUCKET_NAME:-"lambda-triggered-s3-bucket-$(date +%s)"}
LAMBDA_NAME=${LAMBDA_NAME:-"S3ChangeNotificationLambda"}

# Create IAM Role
echo "Creating IAM Role..."
aws iam create-role --role-name LambdaExecutionRole --assume-role-policy-document file://trust-policy.json
aws iam attach-role-policy --role-name LambdaExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
echo "IAM Role created."

# Create S3 Bucket
echo "Creating S3 Bucket..."
aws s3 mb s3://$BUCKET_NAME
echo "S3 Bucket created."

# Create Lambda Function
echo "Creating Lambda Function..."
cat << EOF > lambda_function.py
import json
import boto3

def lambda_handler(event, context):
    print("New object added to S3 bucket:", event)
    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent!')
    }
EOF
zip function.zip lambda_function.py
aws lambda create-function --function-name $LAMBDA_NAME --zip-file fileb://function.zip --handler lambda_function.lambda_handler --runtime python3.8 --role arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):role/LambdaExecutionRole
echo "Lambda Function created."

# Create SNS Topic
echo "Creating SNS Topic..."
TOPIC_ARN=$(aws sns create-topic --name S3BucketNotificationTopic --query "TopicArn" --output text)
aws sns subscribe --topic-arn $TOPIC_ARN --protocol email --notification-endpoint $EMAIL
echo "SNS Topic and Subscription created."

# Set up S3 bucket to send events to Lambda
echo "Configuring S3 bucket to send notifications to Lambda..."
aws s3api put-bucket-notification-configuration --bucket $BUCKET_NAME --notification-configuration '{
    "LambdaFunctionConfigurations": [
        {
            "LambdaFunctionArn": "$(aws lambda get-function --function-name $LAMBDA_NAME --query 'Configuration.FunctionArn' --output text)",
            "Events": [
                "s3:ObjectCreated:*",
                "s3:ObjectRemoved:*"
            ]
        }
    ]
}'
echo "Notification configuration set for S3 bucket."

echo "All tasks completed. Please check your email ($EMAIL) to confirm the subscription."
