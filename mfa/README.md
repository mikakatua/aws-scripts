# Multi Factor Authentication with AWS CLI

## Before you begin
You need to have installed and configured correctly the AWS command line utility. If not, follow the steps in [Installing the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Installation
Download the files and copy them to the right place:
```
$HOME
├── .aws
│   └── mfa.cfg
├── bin
│   └── aws-mfa.env
└── .bash_aliases*

(*) This file should already exists. Append the contents to your file.
```
If you modified the `~/.bash_aliases` then you need to reload it running:
```
source ~/.bash_alisases
```
Edit the `~/.aws/mfa.cfg` sample file and set the ARN of your profiles (AWS accounts with MFA enabled). **IMPORTANT:** The profile names must match with the ones defined in `~/.aws/config`

## Usage
Before run any AWS CLI command you will need to get a session token running:
```
aws-mfa <mfacode> [<aws-profile>]
Where:
   <mfacode> = Code from your assigned MFA device
   <aws-profile> = aws-cli profile usually in ~/.aws/config
```
The obtained token will be valid for 129,600 seconds (36 hours).

## References
* [aws-mfa-script](https://github.com/asagage/aws-mfa-script)
