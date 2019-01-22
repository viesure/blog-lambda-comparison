#!/bin/bash
set -e

# This script sets up and deploys 2 Stacks: One for the lambdas, and one for an EC2 instance to execute the gatling tests

KEYPAIR=viesure-blog-gatling
KEYFILE=${KEYPAIR}.pem
STACK_LAMBDA=viesure-blog-lambda
STACK_GATLING=viesure-blog-gatling
BUCKET=${STACK_LAMBDA}-$(date +%s)
AWS_TEMPLATE=transformed_lambda_template.yaml
LOG=deploy_log.txt

function ensureKeyPair {
  if [[ -f "${KEYFILE}" ]]; then
    echo "Reusing key-pair '${KEYPAIR}'"
  else
    echo "Creating key-pair '${KEYPAIR}''"
    ssh-keygen -q -b 2048 -t rsa -f ${KEYPAIR}.pem -N "" >> $LOG
  fi

  if ! aws ec2 describe-key-pairs | grep ${KEYPAIR} > /dev/null; then
    echo "Uploading key to EC2"
    aws ec2 import-key-pair --key-name ${KEYPAIR} --public-key-material file://${KEYFILE}.pub >> $LOG
  fi
  chmod 400 ${KEYFILE}
}

function extract {
  sed -n "/"$1"/p" < /dev/stdin | sed -E 's/[ \t]*".+".*"([a-zA-Z0-9_-]+)".*/\1/'
}

function waitOnStack {
  echo -n "Waiting for stack '$1'..."
  # The instance id is in the output of the status. Thanks to the filter we either get one output or none
  while true; do
    status=$(aws cloudformation describe-stacks --stack-name $1 | extract StackStatus)
    if [[ ${status} == "CREATE_COMPLETE" || ${status} == "UPDATE_COMPLETE" ]]; then
      break
    elif [[ ${status} =~ "ROLLBACK" ]]; then
      echo "Error, stack in status '${status}''"
      exit 1
    fi
    sleep 5
    echo -n "."
    sleep 5
    echo -n "."
  done
  echo "up!"
}

rm ${LOG}
# Prepare S3 Bucket, Keypair and Lambda cloudformation template
echo "Using bucket '${BUCKET}''"
aws s3 mb s3://${BUCKET} >> $LOG
ensureKeyPair
aws cloudformation package --template-file sam_template.yaml --output-template-file ${AWS_TEMPLATE} --s3-bucket ${BUCKET} >> $LOG

# Start up the Lambda stack
echo "Starting lambda stack '${STACK_LAMBDA}'"
aws cloudformation deploy --template-file ${AWS_TEMPLATE} --stack-name ${STACK_LAMBDA} --capabilities CAPABILITY_IAM >> $LOG
# Start up the EC2 Stack for the gatling tests
echo "Starting EC2 stack '${STACK_GATLING}'"
aws cloudformation create-stack --stack-name ${STACK_GATLING} --template-body file://cloudformation_template.yaml --parameters ParameterKey=KeyPairName,ParameterValue=${KEYPAIR} >> $LOG


# Wait for lambda stack to finish starting. The lambda stack should start faster
waitOnStack ${STACK_LAMBDA}

# There is no way of obtaining the invokation url, we have to use the naming convention:
# https://<restApiId>.execute-api.<awsRegion>.amazonaws.com/<stageName>
# We use Prod as a region, which is created by default
restapiid=$(aws cloudformation describe-stack-resource --stack-name ${STACK_LAMBDA} --logical-resource-id ServerlessRestApi | extract PhysicalResourceId)
url=https://${restapiid}.execute-api.$(aws configure get region).amazonaws.com/Prod
echo "RestAPI Url: ${url}"


waitOnStack ${STACK_GATLING}
instanceid=$(aws cloudformation describe-stack-resource --stack-name ${STACK_GATLING} --logical-resource-id GatlingEc2Instance | sed -n '/"PhysicalResourceId"/p' | grep -e "i-[a-z0-9]*" -o)
publicdns=$(aws ec2 describe-instances --instance-ids ${instanceid} | sed -n "/PublicDnsName/p" | head -1 | grep -o -e "ec2-.*\.com")
echo "Connecting to Host: ${publicdns}"
sshhost=ec2-user@${publicdns}

echo ""
echo "Setup Docker on EC2 Instance"
# Setup docker, see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html
ssh -i ${KEYFILE} -o StrictHostKeyChecking=no ${sshhost} << HERE
 sudo yum update -y
 sudo amazon-linux-extras install docker
 sudo service docker start
 sudo usermod -a -G docker ec2-user
 mkdir ~/gatling
HERE

echo ""
echo "Copying Gatling resources"
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./gatling/conf ${sshhost}:~/gatling
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./gatling/user-files ${sshhost}:~/gatling
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./run_gatling.sh ${sshhost}:~

echo ""
echo "Run Gatling"
ssh -i ${KEYFILE} -o StrictHostKeyChecking=no ${sshhost} << HERE
  ./run_gatling.sh ${url}
  cd gatling
  zip -r results.zip results
HERE

echo ""
echo "Fetching results and uploading to S3"
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ${sshhost}:~/gatling/results.zip ./results.zip
aws s3 cp ./results.zip s3://${BUCKET}

echo "Shutting down EC2 stack"
aws cloudformation delete-stack --stack-name ${STACK_GATLING} >> $LOG