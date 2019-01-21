#!/bin/bash
AMI=ami-0eaec5838478eb0ba
KEYPAIR=viesure-blog-gatling
KEYFILE=${KEYPAIR}.pem
STACKNAME=viesure-blog-gatling

# Create a key pair for our ec2 instance
###keyresponse=$(aws ec2 create-key-pair --key-name ${KEYPAIR})
###keyresponse=$(echo keyresponse)
##privatekey=$(aws ec2 create-key-pair --key-name ${KEYPAIR} | sed -n '/"KeyMaterial": ".*"/p' | grep -e "---.*---" -o)
##echo ${privatekey} > ${KEYPAIR}.pem
if [[ -f "${KEYFILE}" ]]; then
  echo "Reusing key-pair ${KEYPAIR}"
else
  echo "Creating key-pair ${KEYPAIR}"
  ssh-keygen -q -b 2048 -t rsa -f ${KEYPAIR}.pem -N ""
fi

#echo $privatekey

# Create EC2 instance
echo "Starting EC2 instance..."
aws cloudformation create-stack --stack-name ${STACKNAME} --template-body file://cloudformation.template --parameters ParameterKey=KeyPairName,ParameterValue=${KEYPAIR}

##ec2response=$(aws ec2 run-instances --image-id ${AMI} --count 1 --instance-type t2.micro --key-name ${KEYPAIR}) --tag-specification Name=gatling-test
#instanceid=$(aws ec2 run-instances --image-id ${AMI} --count 1 --instance-type t2.micro --key-name ${KEYPAIR} | sed -n '/"InstanceId"/p' | grep -e "i-[a-z0-9]*" -o)

#echo "Instance-ID: ${instanceid}"
#aws ec2 create-tags --resources ${instanceId} --tags Key=Name,Value=viesure-blog-gatling-test
echo -n "Waiting for instance to become running..."
# The instance id is in the output of the status. Thanks to the filter we either get one output or none
#while ! aws ec2 describe-instance-status --filters Name=instance-state-name,Values=running --instance-ids ${instanceId} | grep "${instanceId}"; do
while true; do
  status=$(aws cloudformation describe-stacks --stack-name ${STACKNAME} | sed -n '/StackStatus/p')
  if grep -q 'CREATE_COMPLETE' <<< "${status}"; then
    break
  elif ! grep -q 'CREATE' <<< "${status}"; then
    echo "Error, check stack status"
    exit 1
  fi
  sleep 5
  echo -n "."
  sleep 5
  echo -n "."
done
echo -n "up!"

instanceid=$(aws cloudformation describe-stack-resource --stack-name ${STACKNAME} --logical-resource-id GatlingEc2Instance | sed -n '/"PhysicalResourceId"/p' | grep -e "i-[a-z0-9]*" -o)
publicdns=$(aws ec2 describe-instances --instance-ids ${instanceid} | sed -n "/PublicDnsName/p" | head -1 | grep -o -e "ec2-.*\.com")
echo "Connecting to Host: ${publicdns}"
sshhost=ec2-user@${publicdns}

echo "#####"
echo "Copying Gatling resources"
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./gatling/conf ${sshhost}:~/gatling/conf
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./gatling/user-files ${sshhost}:~/gatling/user-files
scp -r -i ${KEYFILE} -o StrictHostKeyChecking=no ./run_gatling.sh ${sshhost}:~

echo "####"
echo "Setup Docker and start Gatling"
ssh -i ${KEYFILE} -o StrictHostKeyChecking=no ${sshhost} ./run_gatling.sh
