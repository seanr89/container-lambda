variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "my-unique-lambda-trigger-bucket"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "my-s3-triggered-lambda"
}

variable "ecr_image_uri" {
  description = "URI of the ECR image for the Lambda function"
  type        = string
}
