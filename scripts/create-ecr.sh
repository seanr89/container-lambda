#!/bin/bash

# Check if a repository name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <repository-name>"
  exit 1
fi

REPO_NAME=$1

# Create the ECR repository
aws ecr create-repository \
  --repository-name ${REPO_NAME} \
  --image-tag-mutability MUTABLE \
  --region eu-west-1

# Check if the repository was created successfully
if [ $? -eq 0 ]; then
  echo "ECR repository '${REPO_NAME}' created successfully."
else
  echo "Error creating ECR repository '${REPO_NAME}'."
fi
