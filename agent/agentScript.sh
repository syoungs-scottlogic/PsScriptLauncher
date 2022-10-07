#!/bin/bash
#variables
INSTANCEID=$(ec2-metadata -i | grep -E -o '(i-)\w+')
BUCKET="sy-scriptlaunchtest"
FILES="scripts/*"

# copy contents of bucket
COPYFILE=$(aws s3 cp s3://${BUCKET}/${INSTANCEID} scripts/. --recursive)

# delete contents of s3 bucket.
aws s3 rm s3://${BUCKET}/${INSTANCEID}/ --recursive

# Make files executable and then remove files. 
for file in $FILES
do
    chmod +x $file
done

for file in $FILES
do
    ./$file
done

for file in $FILES
do
    rm -f $file
done
