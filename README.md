# PsScriptLauncher

## Goal

This script is used as a small tool to centrally launch scripts on AWS EC2 Instances. Currently build for Windows and Powershell. This has not been tested on cross-platform Powershell.

## Prerequisites

Please ensure the following is configured before using the script:

    * AWS CLI
    * AWS CLI Credentials.
    * Appropriate access in AWS.

## How does it work?

The Main.ps1 script lives in the root directory and any scripts to be sent go into the sub-directory sh-scripts. In truth any file can be places into the folder to be pushed to an instance, but it is assumed this tool is used for shell scripts.

```
PsScriptLauncher/
├─ sh-scripts/
│ ├─ exampleScript1.sh
│ ├─ exampleScript2.sh
├─ Main.ps1
├─ README.md
```

### Technical

The script will begin by asking for your AWS profile and then list all instances by their unique instanceID and friendly name, this is done dynamically via the AWS CLI. **NOTE**: the friendly name is simply a tag in AWS, and instances can share the same friendly name. If this is the case please double check the Instance ID and ensure you are working with the correct instance.

The script will then list the available scripts in the directory `.\sh-scripts_` After confirmation the script will be placed into the S3 bucket via AWS CLI. A directory will be created in the bucket with the Indstance ID and the file placed in that directory (if there is no current directory, one will automatically be created).

**"DRAFT"**
From there the Powershell script has finished it's job. The EC2 instance will poll the directory matching it's own name on the bucket and pull down the file, deleting it from S3 afterwards. The instance will then run the script.
