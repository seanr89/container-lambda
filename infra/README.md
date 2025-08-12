# Infrastructure Overview

This directory contains the Terraform configuration for deploying the AWS Lambda function as a container image.

## Files:

- `main.tf`: Defines the core AWS resources, including the Lambda function, ECR repository for the container image, and potentially an API Gateway for invoking the Lambda.
- `outputs.tf`: Specifies the output values from the Terraform deployment, such as the Lambda function ARN or the API Gateway endpoint URL.
- `providers.tf`: Configures the AWS provider and specifies the required Terraform version.
- `variables.tf`: Declares input variables for the Terraform module, allowing for customization of the deployment (e.g., region, function name, memory size).

## Usage:

To deploy the infrastructure, navigate to this directory and run the following Terraform commands:

1.  **Initialize Terraform**: This command initializes a working directory containing Terraform configuration files.
    ```bash
    terraform init
    ```

2.  **Review the plan**: This command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
    ```bash
    terraform plan
    ```

3.  **Apply the changes**: This command executes the actions proposed in a Terraform plan to create, update, or destroy infrastructure.
    ```bash
    terraform apply
    ```

To destroy the deployed infrastructure:

```bash
terraform destroy
```
