#!/bin/bash
set -euo pipefail

# Variables
AWS_ACCOUNT_ID=553253085605
##$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${1:-"eu-west-1"}
ECR_REPOSITORY_NAME=${2:-"eventlambda"}
IMAGE_TAG="latest"

# Change to the eventlambda directory
cd "$(dirname "$0")/../eventlambda"

echo "Building and pushing image to ${ECR_REPOSITORY_NAME} in ${AWS_REGION}"

# Authenticate Docker to your ECR registry
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Build the Docker image
docker build -t ${ECR_REPOSITORY_NAME}:${IMAGE_TAG} .

# Tag the image for ECR
docker tag ${ECR_REPOSITORY_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}

# Push the image to ECR
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}

echo "Image pushed successfully"
