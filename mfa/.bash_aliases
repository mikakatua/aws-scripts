getAWSToken() {
  bash ~/bin/aws-mfa.env $1 $2
  if [ $? -eq 0 ]
  then
    . ~/.aws/environ
    echo "Your creds have been set in your env."
  fi
}
alias aws-mfa=getAWSToken
