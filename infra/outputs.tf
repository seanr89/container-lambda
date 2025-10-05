output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = aws_s3_bucket.lambda_trigger_bucket.id
}

output "sqs_queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.event_queue.url
}
