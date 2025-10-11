variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "container-lambda-bucket"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my-s3-triggered-lambda"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository for the main Lambda function"
  type        = string
  default     = "container-lambda"
}

variable "event_lambda_repository_name" {
  description = "Name of the ECR repository for the event Lambda function"
  type        = string
  default     = "eventlambda"
}