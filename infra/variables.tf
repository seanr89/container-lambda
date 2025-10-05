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

variable "ecr_image_uri" {
  description = "URI of the ECR image for the Lambda function"
  type        = string
  default     = "553253085605.dkr.ecr.eu-west-1.amazonaws.com/container-lambda:latest"
}
