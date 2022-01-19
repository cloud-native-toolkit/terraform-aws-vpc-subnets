#!/bin/bash
SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
echo "SCRIPT_DIR: ${SCRIPT_DIR}"
PREFIX_NAME=$(cat terraform.tfvars | grep prefix_name | sed "s/prefix_name=//g" | sed 's/"//g' | sed "s/_/-/g")
REGION=$(cat terraform.tfvars | grep -E "^region" | sed "s/region=//g" | sed 's/"//g')
VPC_NAME="${PREFIX_NAME}-vpc"

echo "VPC_NAME: ${VPC_NAME}"
echo "REGION: ${REGION}"


num_of_public_subnets=$(cat terraform.tfvars | grep -E "^num_of_public_subnets" | sed "s/num_of_public_subnets=//g" | sed 's/"//g')
num_of_private_subnets=$(cat terraform.tfvars | grep num_of_private_subnets | sed "s/num_of_private_subnets=//g" | sed 's/"//g' | sed "s/_/-/g")

echo "Number of Public subnets  : ${num_of_public_subnets}"
echo "Number of Private subnets : ${num_of_private_subnets}"

aws configure set region ${REGION}
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}

echo "Checking VPC exists with Name in AWS: ${VPC_NAME}"

VPC_ID=""
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=swe-vpc"  --query 'Vpcs[0].VpcId' --output=json --no-paginate)

echo "VPC_ID: ${VPC_ID}"
if [[(${VPC_ID} == "") ]]; then
  echo "VPC NOT found "
   exit 1
else
    echo "VPC Found - ${VPC_ID}"    
fi


no_of_pub_subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:tier,Values=public" --query 'length(Subnets)' --output=text --no-paginate)

# echo "Number of pub subnets created the VPC ID ${VPC_ID} is ${no_of_pub_subnets}"

no_of_pri_subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:tier,Values=private" --query 'length(Subnets)' --output=text --no-paginate)

# echo "Number of private subnets created the VPC ID ${VPC_ID} is ${no_of_pri_subnets}"

subnets_created=true
if [[(${num_of_public_subnets} > 0) && (${num_of_public_subnets} == ${no_of_pub_subnets})]];then
    echo "No. of Publics Subnets created:  ${no_of_pub_subnets} "
else 
    echo "No Public Subnets created "
    subnets_created=false
    exit 1
fi

if [[(${num_of_private_subnets} > 0 )&&(${num_of_private_subnets} == ${no_of_pri_subnets})]]; then
    echo "No. of privates Subnets created:  ${no_of_pri_subnets} "    
else 
    echo "No Private Subnets created "
    exit 1
fi

echo "All Good" 
exit 0