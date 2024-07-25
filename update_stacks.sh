#!/bin/bash

set -e

# Convert parameters to string
echo "Converting parameters to string"
PUBLIC_SUBNETS=$(echo "${PublicSubnets}" | jq -R -s -c 'split(" ") | join(",")' | tr -d '\n')
echo "PublicSubnets as string: $PUBLIC_SUBNETS"

# Check and deploy/update test-alb if changes are detected
echo "Checking changes for test-alb"
if aws cloudformation describe-stacks --stack-name test-alb >/dev/null 2>&1; then
  echo "Updating test-alb...."
  aws cloudformation create-change-set \
    --stack-name test-alb \
    --template-url https://test--template.s3.amazonaws.com/test-alb.yml \
    --change-set-name test-alb-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameters file://parameters.json
  aws cloudformation wait change-set-create-complete \
    --stack-name test-alb \
    --change-set-name test-alb-changeset
  aws cloudformation describe-change-set \
    --stack-name test-alb \
    --change-set-name test-alb-changeset
else
  echo "Stack test-alb does not exist. No changes applied."
fi
