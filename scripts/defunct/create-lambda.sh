#!/bin/bash
set -euo pipefail

cd ../nodelambda

echo "creating lambda"

aws lambda create-function \
    --function-name TestFunction \
    --runtime nodejs20.x \
    --handler index.handler \
    --role arn:aws:iam::553253085605:role/MyLambdaRole \
    --zip-file fileb://../nodelambda/deployment_package.zip \
    --description "My new Node.js Lambda function" \
    --timeout 30 \
    --memory 128 \
    --region eu-west-1 # Add your desired AWS region here

echo "Done"x
exit 0