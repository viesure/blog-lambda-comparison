#!/bin/bash
# This script deletes all resources created by the deploy script.
# BEWARE! It has to match a few things with wildcards and might delete data you might want to keep!

KEYPAIR=viesure-blog-lambda-test
STACK_LAMBDA=viesure-blog-lambda
AWS_TEMPLATE=transformed_lambda_template.yaml
LOG=deploy.log

# delete temp files
rm -f AWS_TEMPLATE LOG
# delete lambda stack
aws cloudformation delete-stack --stack-name ${STACK_LAMBDA}
# delete ALL logs from lambdas
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/viesure-blog | grep -E "(logGroupName.*)(Python|Java|NodeJs)Lambda" | grep -Eo '/aws/lambda/[a-zA-Z0-9-]*' | xargs -n1 aws logs delete-log-group --log-group-name
# delete ALL buckets from lambdas
aws s3 ls | grep -oe "${STACK_LAMBDA}.*" | xargs -n1 -I {} aws s3 rb s3://{} --force
