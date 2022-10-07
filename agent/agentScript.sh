#!/bin/bash
#variables
INSTANCEID=$(ec2-metadata -i | grep -E -o '(i-)\w+')
BUCKET="sy-scriptlaunchtest"
FILES="scripts/*"
# Get Instance ID on machine. 

# instance-id: i-0da6eed6ab8a045a2


# copy contents of bucket
COPYFILE=$(aws s3 cp s3://${BUCKET}/${INSTANCEID} scripts/. --recursive)
# delete contents of s3 bucket.
aws s3 rm s3://${BUCKET}/${INSTANCEID}/ --recursive
# make file(s) executable -- chmod +x FILENAME
## forech file in dir 
for file in $FILES
do
    chmod +x $file
done

for file in $FILES
do
    ./$file
done

# * * * * * /bin/bash /home/ec2-user/agentScript.sh