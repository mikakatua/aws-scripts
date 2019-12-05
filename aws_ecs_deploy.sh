#!/bin/bash
ECS_CLUSTER=$1
ECS_SERVICE=$2
ECR_REPO=$3
GIT_REPO=$4
GIT_BRANCH=$5
GIT_ADDRESS=git@gitlab.example.com
ECR_ADDRESS=012345678901.dkr.ecr.us-west-1.amazonaws.com
AWS_REGION=us-west-1
TMP_DIR=/tmp

usage()
{
cat <<!
  aws_ecs_deploy.sh <ecs-cluster> <ecs-service> <ecr-repo> <git-repo> [<git-branch>]
  
  ecs-cluster: ECS Cluster name
  ecs-service: ECS Service name
  ecr-repo: ECR Repositori name
  git-repo: Git Project path (without .git)
  git-branch: optional (default master)
!
}

if [ ! "$GIT_REPO" ]
then
  usage
  exit 1
fi

if [ "$GIT_BRANCH" ]
then
  git_args="-b $GIT_BRANCH"
fi

# Exit when any command fails
set -e

# Clone Repository
rm -rf $TMP_DIR/$GIT_REPO 2>/dev/null
git clone $git_args $GIT_ADDRESS:$GIT_REPO.git $TMP_DIR/$GIT_REPO
cd $TMP_DIR/$GIT_REPO

# Build & Push
$(aws ecr get-login --no-include-email --region $AWS_REGION | sed 's|https://||')
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $ECR_ADDRESS/$ECR_REPO:latest
docker push $ECR_ADDRESS/$ECR_REPO:latest

# Stop Tasks
TASKS=$(aws ecs list-tasks --cluster $ECS_CLUSTER --service $ECS_SERVICE --query "taskArns[*]")
for TASK_ARN in $TASKS
do
  aws ecs stop-task --cluster $ECS_CLUSTER --task $TASK_ARN &> /dev/null
done

# Wait until all tasks are running
set +e
while true
do
  TASKS=$(aws ecs list-tasks --cluster $ECS_CLUSTER --service $ECS_SERVICE --query "taskArns[*]")
  aws ecs describe-tasks --cluster $ECS_CLUSTER --tasks $TASKS --query "tasks[*][taskArn,lastStatus]"
  sleep 2
done

