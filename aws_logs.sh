#!/bin/bash
LOG_GROUP=$1
START_DATE=$2

function usage
{
cat <<!
  aws_logs.sh <log-group> [<start-date>]

  log-group: AWS CloudWatch log group name
  start-date: 24h date (format "yyyy-mm-dd hh:mm:ss")
!
}

if [ ! "$LOG_GROUP" ]
then
  usage
  exit 1
fi
 
if [ "$START_DATE" ]
then
  START=$(date --date "$START_DATE" +%s)000
  GETLOGEVENTS_ARGS="$GETLOGEVENTS_ARGS --start-time $START"
else
  START=0
fi

while read LOG_STREAM FIRST_EVENT LAST_EVENT
do
  if [ $FIRST_EVENT -le $START -a $START -le $LAST_EVENT -o $START -le $FIRST_EVENT ]
  then
    line=$(echo $LOG_STREAM $FIRST_EVENT $LAST_EVENT | awk '{$2=strftime("%Y-%m-%d %H:%M:%S", $2/1000);$3=strftime("%Y-%m-%d %H:%M:%S", $3/1000); print $0}')
    echo -e "\n\033[1m$line:\033[0m"
    aws logs get-log-events --log-group-name $LOG_GROUP --log-stream-name $LOG_STREAM --query "events[*].[timestamp,message]" $GETLOGEVENTS_ARGS | awk '{$1=strftime("%Y-%m-%d %H:%M:%S", $1/1000); print $0}'
  fi
done < <(aws logs describe-log-streams --log-group-name $LOG_GROUP --query "logStreams[*].[logStreamName,firstEventTimestamp,lastEventTimestamp]" | sort -n -k 2)

