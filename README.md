# PsScriptLauncher

## Goal

This script is used as a small tool to centrally launch scripts on AWS EC2 Instances. Currently the Main.ps1 file has been build for Windows PowerShell and has not been tested on cross-platform Powershell. The back-end agent has only been tested on Amazon Linux 2.

## Prerequisites

Please ensure the following is configured before using the script:

    - AWS CLI (both locally and on EC2 Instance(s))
    - AWS CLI Credentials.
    - Appropriate access in AWS.
    - AWS role, bucket policy and permissions.

## How does it work?

The Main.ps1 script lives in the root directory and any scripts to be sent go into the sub-directory `/sh-scripts`. In truth any file can be placed into the folder to be pushed to an instance, but it is assumed this tool is used for shell scripts.

From the PowerShell front-end, a script is sent to an S3 bucket, creating a folder with the specified instance ID. The EC2 instance(s) poll the bucket and pull down any scripts it finds. The instance will then delete the items in bucket/folder. The instance will then run the script and upon completion, delete the script locally.

```
PsScriptLauncher/
├─ agent/
│  ├─ agentScript.sh
├─ sh-scripts/
│  ├─ exampleScript1.sh
│  ├─ exampleScript2.sh
├─ Main.ps1
├─ README.md
```

### Technical

The script will begin by asking for your AWS profile and then list all instances by their unique instanceID and friendly name, this is done dynamically via the AWS CLI. **NOTE**: the friendly name is simply a tag in AWS, any instances which don't have a friendly name will show as "None", and instances can share the same friendly name. If this is the case please double check the Instance ID and ensure you are working with the correct instance.

The script will then list the available scripts in the directory `.\sh-scripts` After confirmation the script will be placed into the S3 bucket via AWS CLI. A directory will be created in the bucket with the Indstance ID and the file placed in that directory (if there is no current directory, one will automatically be created).

From there the Powershell script has finished it's job and will close on your side. Scheduled by a cron job, the EC2 instance will poll the directory matching it's own name on the bucket and pull down the file, deleting it from S3 afterwards. The instance will then run the script and also delete it locally upon completion. This also ensures instances will not grab scripts which are destined for other instances.

## Configuration

To use this tool in new environments, some configuration will have to take place. Firstly, it is critical your AWS CLI profile is configured and you know what profile you are using.

### AWS

Best practice for this tool is to set up a bucket solely for the purpose of holding scripts. This should **NOT** be used in a bucket holding client data. The bucket should be left private.
An IAM role can then be created with the purpose of granting the necessary instances access to the bucket, and the bucket should be locked down with a policy reflecting this. Once the role is set for the EC2 instances, the CLI profile can be configured to use the role on the instances.

### Code

In `Main.ps1` the variable `$bucket` can be edited to use any bucket you wish for easier portability between environments. The same variable is also noted in agentScript.sh as `BUCKET=`, and should be edited to reflect what is in `Main.ps1`.

### Agent.

The file `PsScriptLauncher/agent/agentScript.sh` is the back-end tool used to run the scripts. Once this script is on the instance, it should be configured as an executable `chmod +x agentScript.sh` and a cronjob can be configured for this. Is is fine for this to be kept in the default root user pwd, and the crontab entry is: `* * * * * /bin/bash /home/ec2-user/agentScript.sh`, which will run the job every minute.
