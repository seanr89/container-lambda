resource "random_id" "id" {
  byte_length = 8
}

resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = "${var.s3_bucket_name}-${random_id.id.hex}"
}

resource "aws_s3_bucket_ownership_controls" "lambda_trigger_bucket_ownership" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_trigger_bucket_public_access" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "s3_read_policy" {
  name = "${var.lambda_function_name}-s3-read-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
        ],
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.lambda_trigger_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_lambda_function" "s3_triggered_lambda" {
  function_name = var.lambda_function_name
  package_type  = "Image"
  image_uri     = var.ecr_image_uri
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 300
  memory_size   = 128
  architectures = ["arm64"]

  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.event_queue.url
    }
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_triggered_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_trigger_bucket.arn
}

resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_triggered_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke,
    aws_s3_bucket_ownership_controls.lambda_trigger_bucket_ownership
  ]
}

resource "aws_sqs_queue" "event_queue" {
  name = "${var.lambda_function_name}-queue"
}

resource "aws_iam_role_policy" "sqs_send_policy" {
  name = "${var.lambda_function_name}-sqs-send-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:SendMessage",
        ],
        Effect   = "Allow"
        Resource = aws_sqs_queue.event_queue.arn
      },
    ]
  })
}
