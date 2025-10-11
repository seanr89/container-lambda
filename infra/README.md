# Infrastructure Overview

This directory contains the Terraform configuration for deploying the AWS infrastructure for the containerized Lambda functions.

The infrastructure consists of:
*   An S3 bucket that triggers a Lambda function on object creation.
*   An SQS queue that receives messages from the first Lambda function.
*   An S3-triggered Lambda function (`s3_triggered_lambda`) that is packaged as a container image. This function is triggered by files being uploaded to the S3 bucket and it writes a message to the SQS queue.
*   An SQS-triggered Lambda function (`sqs_triggered_lambda`) that is also packaged as a container image. This function is triggered by messages in the SQS queue.
*   The necessary IAM roles and policies for the Lambdas to execute and access other AWS resources.

## Files:

- `main.tf`: Defines the core AWS resources, including the S3 bucket, SQS queue, IAM roles, and the two Lambda functions.
- `outputs.tf`: Specifies the output values from the Terraform deployment, such as the Lambda function ARNs and the S3 bucket name.
- `providers.tf`: Configures the AWS provider and specifies the required Terraform version.
- `variables.tf`: Declares input variables for the Terraform module. This includes the AWS region, S3 bucket name, Lambda function names, and the ECR repository names (`ecr_repository_name` and `event_lambda_repository_name`).

## Usage:

The `Makefile` in the root directory provides convenience targets for deploying and managing the infrastructure.

To deploy the infrastructure, you can run the following command from the root of the project:

```bash
make apply
```

This will initialize Terraform, create a plan, and apply it. The `apply` target in the `Makefile` passes the ECR repository names to Terraform as variables.

You can customize the ECR repository names by setting the `ECR_REPOSITORY_NAME` and `EVENT_LAMBDA_ECR_REPOSITORY_NAME` environment variables when running the `make` command:

```bash
make apply ECR_REPOSITORY_NAME=my-container-lambda EVENT_LAMBDA_ECR_REPOSITORY_NAME=my-event-lambda
```

### Manual Terraform Commands

If you prefer to run the Terraform commands manually, navigate to this directory and run:

1.  **Initialize Terraform**:
    ```bash
    terraform init
    ```

2.  **Review the plan**:
    ```bash
    terraform plan -var="ecr_repository_name=<your-repo-name>" -var="event_lambda_repository_name=<your-event-repo-name>"
    ```

3.  **Apply the changes**:
    ```bash
    terraform apply -var="ecr_repository_name=<your-repo-name>" -var="event_lambda_repository_name=<your-event-repo-name>"
    ```

To destroy the deployed infrastructure:

```bash
make destroy
```
or
```bash
terraform destroy
```