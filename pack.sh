#!/bin/bash

# Access the AMI ID passed as an argument
AMI_ID=$AMI_ID
# Revoke launch permissions for a specific AWS account
aws ec2 modify-image-attribute \
    --image-id "$AMI_ID" \
    --launch-permission "Remove=[{UserId=280435798514}]"
