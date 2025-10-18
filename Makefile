TF_DIR = infra
ECR_REPOSITORY_NAME ?= container-lambda
EVENT_LAMBDA_ECR_REPOSITORY_NAME ?= eventlambda

.DEFAULT_GOAL := help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m   %s\n", $$1, $$2}'

# build: ## build the docker image
# 	@echo "Building image"
# 	cd nodelambda && docker build -t container-lambda .

.PHONY: init plan apply destroy build

buildevents: ## build the docker image for event lambda
	@echo "Building image for event lambda"
	cd eventlambda && docker build -t event-lambda .

init: ## initialise the terraform
	terraform -chdir=$(TF_DIR) init

plan: ## plan the changes
	terraform -chdir=$(TF_DIR) plan

apply: ## apply the changes
	@echo "Using ECR_REPOSITORY_NAME: $(ECR_REPOSITORY_NAME)"
	@echo "Using EVENT_LAMBDA_ECR_REPOSITORY_NAME: $(EVENT_LAMBDA_ECR_REPOSITORY_NAME)"
	terraform -chdir=$(TF_DIR) apply -var="ecr_repository_name=$(ECR_REPOSITORY_NAME)" -var="event_lambda_repository_name=$(EVENT_LAMBDA_ECR_REPOSITORY_NAME)" -auto-approve

apply-sqs-lambda: ## apply the changes
	echo "Remember to provide the ECR_REPOSITORY_NAME and EVENT_LAMBDA_ECR_REPOSITORY_NAME, e.g., make apply"

destroy: ## destroy the resources
	terraform -chdir=$(TF_DIR) destroy

upload-storage-docker: ## upload the docker image to s3
	@echo "Uploading image to S3"
	cd scripts && ./push_image.sh

upload-event-lambda-docker: ## upload the event lambda docker image to ecr
	@echo "Uploading event lambda image to ECR"
	cd scripts && ./push_event_lambda_image.sh
