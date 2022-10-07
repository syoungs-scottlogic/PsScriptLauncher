#!/usr/bin/bash

# Get Instance ID on machine. 
INSTANCEID=$(ec2-metadata -i | grep -E -o '(i-)\w+')
# instance-id: i-0da6eed6ab8a045a2

BUCKET="sy-scriptlaunchtest"
aws s3 cp s3://${BUCKET}/${INSTANCEID}/ ./ --recursive