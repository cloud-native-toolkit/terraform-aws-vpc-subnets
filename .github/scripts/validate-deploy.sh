#!/bin/bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
echo "SCRIPT_DIR: ${SCRIPT_DIR}"
export VPC_ID=$(terraform output -json | jq -r '."vpc_id".value')
REGION=$(cat terraform.tfvars | grep -E "^region" | sed "s/region=//g" | sed 's/"//g')

echo "VPC_ID: ${VPC_ID}"
echo "REGION: ${REGION}"

aws configure set region ${REGION}
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}

echo "Checking VPC exists with ID in AWS: ${VPC_ID}"
VPC_ID_OUT=$(aws ec2 describe-vpcs --vpc-ids $VPC_ID --query 'Vpcs[0].VpcId' --output=text) 

echo "VPC_ID_OUT: $VPC_ID_OUT"
if [[ ( $VPC_ID_OUT == $VPC_ID) ]]; then
  echo "VPC id found: ${VPC_ID_OUT}"
    exit 0  
else
    echo "VPC Not Found"
fi

exit 1