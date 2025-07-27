#!/bin/bash
set -euo pipefail

aws iam create-role --role-name MyLambdaRole --assume-role-policy-document file://lambda-trust-policy.json