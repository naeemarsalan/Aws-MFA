#!/bin/bash

if test `find ~/.aws/vars -mmin -720`
then
    aws s3 ls 2>/dev/null 1>/dev/null
    if [ $? -eq 0 ]
    then
	echo "AWS Creds Configured and Tested"
    	exit 0
    fi
fi


unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN

ACC_NUM="912345144461"
USER="mnaeem"


echo "Please entry Token:"
read token


resp=$(aws sts get-session-token --serial-number arn:aws:iam::${ACC_NUM}:mfa/${USER} --token-code ${token} --duration-seconds 129600 )

SAkey=$(echo $resp | jq '.Credentials["SecretAccessKey"]' | tr -d '"')
ST=$(echo $resp | jq '.Credentials["SessionToken"]' | tr -d '"')
AKey=$(echo $resp | jq '.Credentials["AccessKeyId"]' | tr -d '"')

sed -i '7,$d' ~/.aws/credentials 

echo "aws_access_key_id = $AKey" >> ~/.aws/credentials
echo "aws_secret_access_key = $SAkey" >> ~/.aws/credentials
echo "aws_session_token = $ST" >> ~/.aws/credentials


echo "export AWS_ACCESS_KEY_ID=$AKey" > ~/.aws/vars
echo "export AWS_SECRET_ACCESS_KEY=$SAkey" >> ~/.aws/vars
echo "export AWS_SESSION_TOKEN=$ST" >> ~/.aws/vars

