#!/bin/bash
ECS_CLUSTER=$1
ECS_SERVICE=$2
ECR_REPO=$3
GIT_REPO=$4
GIT_BRANCH=$5
GIT_ADDRESS=git@gitlab.example.com
ECR_ADDRESS=012345678901.dkr.ecr.us-west-1.amazonaws.com
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
docker rmi -f $(docker images $ECR_REPO -q)
docker build -t $ECR_REPO .
docker tag $ECR_REPO:latest $ECR_ADDRESS/$ECR_REPO:latest
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_ADDRESS/$ECR_REPO
docker push $ECR_ADDRESS/$ECR_REPO:latest

# Stop Tasks
TASKS=$(aws ecs list-tasks --cluster $ECS_CLUSTER --service $ECS_SERVICE --query "taskArns[*]" --output text)
for TASK_ARN in $TASKS
do
  aws ecs stop-task --cluster $ECS_CLUSTER --task $TASK_ARN --output text &> /dev/null
done

# Wait until all tasks are running
set +e
while true
do
  TASKS=$(aws ecs list-tasks --cluster $ECS_CLUSTER --service $ECS_SERVICE --query "taskArns[*]" --output text)
  aws ecs describe-tasks --cluster $ECS_CLUSTER --tasks $TASKS --query "tasks[*][taskArn,lastStatus]" --output text
  sleep 2
done

