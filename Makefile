TF_DIR = infra

.DEFAULT_GOAL := help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m   %s\n", $$1, $$2}'

# build: ## build the docker image
# 	@echo "Building image"
# 	cd nodelambda && docker build -t container-lambda .

.PHONY: init plan apply destroy build

init: ## initialise the terraform
	terraform -chdir=$(TF_DIR) init

plan: ## plan the changes
	terraform -chdir=$(TF_DIR) plan

apply: ## apply the changes
	ECR_IMAGE_URI=553253085605.dkr.ecr.eu-west-1.amazonaws.com/container-lambda:latest
	@echo "Remember to provide the ECR_IMAGE_URI, e.g., make apply ECR_IMAGE_URI=123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest"
	terraform -chdir=$(TF_DIR) apply -var="ecr_image_uri=$(ECR_IMAGE_URI)" -auto-approve

apply-sqs-lambda: ## apply the changes
	echo "Remember to provide the ECR_IMAGE_URI, e.g., make apply"

destroy: ## destroy the resources
	terraform -chdir=$(TF_DIR) destroy


