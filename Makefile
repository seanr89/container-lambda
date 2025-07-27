.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m   %s\n", $$1, $$2}'

build-image: ## build docker image
	@cd ./nodelambda && docker build --platform linux/amd64 --provenance=false -t lambdanode:latest .

local-test: ## test it locally
	docker run --platform linux/amd64 -p 9000:8080 docker-image:test

# update: ## update a lambda job
# 	@bash ./scripts/update-lambda.sh

create-repo: ## create ecr repo
	aws ecr create-repository \
    --repository-name lambdanode \
    --region eu-west-1 \
    --image-tag-mutability MUTABLE \
    --image-scanning-configuration scanOnPush=true

ecr-push: ## push to ecr repo
	docker tag lambdanode:latest 553253085605.dkr.ecr.eu-west-1.amazonaws.com/lambdanode:latest
	aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 553253085605.dkr.ecr.eu-west-1.amazonaws.com
	docker push 553253085605.dkr.ecr.eu-west-1.amazonaws.com/lambdanode:latest

create-func: ## create a lambda func
	aws lambda create-function \
	--function-name my-awesome-app-lambda \
	--package-type Image \
	--code ImageUri=553253085605.dkr.ecr.eu-west-1.amazonaws.com/lambdanode:latest \
	--role arn:aws:iam::553253085605:role/MyLambdaRole \
	--region eu-west-1

update-func: ## update a lambda func
	aws lambda update-function-code \
	--function-name my-awesome-app-lambda \
	--image-uri 553253085605.dkr.ecr.eu-west-1.amazonaws.com/lambdanode:latest \
	--region eu-west-1