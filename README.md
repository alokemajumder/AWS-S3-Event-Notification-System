# AWS S3 Event Notification System

This repository contains a Bash script that automates the creation of several AWS resources to set up a notification system triggered by changes (create or delete actions) in an S3 bucket. This system utilizes AWS services such as IAM, S3, Lambda, and SNS to implement an integrated solution.

## Features

- **IAM Role Creation**: Sets up an IAM role with appropriate permissions for Lambda to execute.
- **S3 Bucket**: Creates an S3 bucket that will store your files and trigger notifications on changes.
- **Lambda Function**: Implements a Lambda function that gets invoked on changes to the S3 bucket.
- **SNS Topic**: Creates an SNS topic and subscribes your email so that you can receive notifications about bucket changes.
- **Bucket Notification Configuration**: Configures the S3 bucket to send events to the Lambda function, thus enabling real-time alerts.

## Prerequisites

Before running the script, ensure you have the following:
- An AWS account with sufficient permissions to create and manage IAM roles, S3 buckets, Lambda functions, and SNS topics.
- AWS CLI installed on your local machine or EC2 instance.
- `zip` utility installed for packaging the Lambda function.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/alokemajumder/AWS-S3-Event-Notification-System.git`` 

2.  Navigate to the cloned directory:
    
    
    `cd AWS-S3-Event-Notification-System` 
    

## Usage

1.  Open a terminal.
2.  Run the script with:
   
    
    `bash setup.sh` 
    
3.  Follow the on-screen prompts to enter your email and optionally name your S3 bucket and Lambda function.
4.  Check your email and confirm the SNS subscription to start receiving notifications.

## Trust Policy

The `trust-policy.json` **( Included in the repo)**  is essential for the IAM role creation, allowing AWS Lambda to assume the role. 

Ensure this file is in the same directory as your script before executing.


## Contributions

We strive to keep the script compatible with the latest AWS CLI versions and functionality. For better maintenance and feature update, any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch
3.  Commit your Changes 
4.  Push to the Branch
5.  Open a Pull Request

**Always open an Issue first and then tag the PR**

## License

This project is licensed under the MIT License 

## Acknowledgments

-   Thanks to AWS for the comprehensive documentation that assisted in the API usage.
-   This script is based on community examples and personal experimentation.
