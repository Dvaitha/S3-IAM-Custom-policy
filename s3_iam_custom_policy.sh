#!/bin/bash

# Prompt user for input
read -p "Enter username for IAM user: " username
read -p "Enter bucket name for S3: " bucketname
read -p "Enter bucket region for S3: " region
echo "Enter the access for the bucket"
# select access in private public-read public-read-write authenticated-read

# List of options
options=("private" "public-read" "public-read-write" "authenticated-read")

# Prompt user to select an option
echo "Select an option for S3 bucket ACL :"
select option in "${options[@]}"; do
  case $option in
    "private")
      echo $option
      break
      ;;
    "public-read")
      echo $option
      break
      ;;
    "public-read-write")
      echo $option
      break
      ;;
    "authenticated-read")
      echo $option
      break
      ;;
    *)
      echo "Invalid option, please try again"
      ;;
  esac
done



# Create IAM user
aws iam create-user --user-name $username

# Create S3 bucket
aws s3api create-bucket --bucket $username --region $region --acl $option

# Create policy JSON file
cat <<EOF > policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$bucketname"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "arn:aws:s3:::$bucketname/*"
            ]
        }
    ]
}
EOF

# Create policy and get ARN
policy_arn=$(aws iam create-policy --policy-name "$username-policy" --policy-document file://policy.json | jq -r '.Policy.Arn')

# Attach policy to IAM user
aws iam attach-user-policy --user-name $username --policy-arn $policy_arn

# Display all details
echo "IAM user created: $username"
echo "S3 bucket created: $bucketname"
echo "Policy ARN: $policy_arn"
echo "Below are the programmatic credentials for $username" 

# Create Programmatic access for the user
aws iam create-access-key --user-name $username

