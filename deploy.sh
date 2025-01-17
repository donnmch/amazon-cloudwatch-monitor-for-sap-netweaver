#!/bin/bash

set -e

releaseID='815fad66ddef02f3bd8603ae7a0895cb' # v.1.09


# Create Bucket if not exists
accountid=$(aws sts get-caller-identity --query Account --output text)
if aws s3 ls "s3://$accountid-sapmonitor" 2>&1 | grep -q 'NoSuchBucket'
then
echo "Create Amazon S3 Bucket to store artifacts"
aws s3 mb s3://$accountid-sapmonitor
fi

# Copy Artifacts
echo "Copy artifacts to S3 Bucket"
aws s3 cp s3://sap-monitor/$releaseID ./ --source-region eu-central-1
aws s3 cp $releaseID s3://$accountid-sapmonitor/$releaseID

# Upload YAML
echo "Adjust AWS CloudFormation Template"
wget https://github.com/aws-samples/amazon-cloudwatch-monitor-for-sap-netweaver/raw/master/packaged.yml
sed -i 's/s3\:\/\/sap-monitor\/'$releaseID'/s3\:\/\/'$accountid'-sapmonitor\/'$releaseID'/g' packaged.yml
aws s3 cp packaged.yml s3://$accountid-sapmonitor/packaged.yml

echo "All Done!"
echo "Create a new AWS CloudFormation stack by selecting Amazon S3 as template source:"
echo "https://$accountid-sapmonitor.s3.amazonaws.com/packaged.yml"