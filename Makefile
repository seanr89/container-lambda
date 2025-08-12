TF_DIR = infra

.DEFAULT_GOAL := help


help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m   %s\n", $$1, $$2}'


.PHONY: init plan apply destroy

init: ## initialise the terraform
	terraform -chdir=$(TF_DIR) init

plan: ## plan the changes
	terraform -chdir=$(TF_DIR) plan

apply: ## apply the changes
	@echo "Remember to provide the ECR_IMAGE_URI, e.g., make apply ECR_IMAGE_URI=123456789012.dkr.ecr.us-east-1.amazonaws.com/my-repo:latest"
	terraform -chdir=$(TF_DIR) apply -var="ecr_image_uri=$(ECR_IMAGE_URI)"

destroy: ## destroy the resources
	terraform -chdir=$(TF_DIR) destroy
