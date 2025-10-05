#!/bin/bash
set -euo pipefail

cd ../nodelambda

zip -r deployment_package.zip index.js

aws lambda update-function-code \
    --function-name TestFunction \
    --zip-file fileb://./deployment_package.zip \
    --region eu-west-1

echo "done"
exit 0