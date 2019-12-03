# My AWS Scripts
Useful AWS scripts:
* [mfa](/mfa): This folder contains a script to automate MFA using the AWS CLI.
* [aws_ecs_deploy.sh](/aws_ecs_deploy.sh): This script helps you to build and deploy containers on AWS ECS
* [aws_logs.sh](/aws_logs.sh): This scripts retrieves logs using the AWS CloudWatch API

## mfa
Read the documentation [here](/mfa)

## aws_ecs_deploy.sh
Before using this script you will need to:
1. Have the AWS CLI installed and configured properly
2. Have access to a Git repository (containing the Dockerfile)
3. Edit the script and set the variables (`GIT_ADDRESS`, `ECR_ADDRESS` and `AWS_REGION`) accoding to your environment

Usage:
```
  aws_ecs_deploy.sh <ecs-cluster> <ecs-service> <ecr-repo> <git-repo> [<git-branch>]
  
  ecs-cluster: ECS Cluster name
  ecs-service: ECS Service name
  ecr-repo: ECR Repositori name
  git-repo: Git Project path (without .git)
  git-branch: optional (default master)
```

## aws_logs.sh
Before using this script you will need to:
1. Have the AWS CLI installed and configured properly

Usage:
```
  aws_logs.sh <log-group> [<start-date>]

  log-group: AWS CloudWatch log group name
  start-date: 24h date (format "yyyy-mm-dd hh:mm:ss")
```
