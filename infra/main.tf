data "aws_ecr_image" "s3_triggered_lambda_image" {
  repository_name = var.ecr_repository_name
  image_tag       = "latest"
}

data "aws_ecr_image" "sqs_triggered_lambda_image" {
  repository_name = var.event_lambda_repository_name
  image_tag       = "latest"
}

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
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:CopyObject"
        ],
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.lambda_trigger_bucket.arn}/*"
      },
    ]
  })
}

resource "aws_lambda_function" "s3_triggered_lambda" {
  function_name = var.lambda_function_name
  description   = "This lambda is triggered by an S3 event and writes the event to an SQS queue."
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.s3_triggered_lambda_image.image_uri
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 300
  memory_size   = 128
  architectures = ["arm64"]
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.event_queue.url,
      REGION = "${var.aws_region}"
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
    filter_prefix       = "inbound/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke,
    aws_s3_bucket_ownership_controls.lambda_trigger_bucket_ownership
  ]
}

resource "aws_sqs_queue" "event_queue" {
  name                       = "${var.lambda_function_name}-queue"
  visibility_timeout_seconds = 300
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

resource "aws_lambda_function" "sqs_triggered_lambda" {
  function_name = "${var.lambda_function_name}-sqs"
  description   = "This lambda is triggered by an SQS event."
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.sqs_triggered_lambda_image.image_uri
  role          = aws_iam_role.lambda_exec_role.arn
  timeout       = 300
  memory_size   = 128
  architectures = ["arm64"]
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.sqs_triggered_lambda.arn
}

resource "aws_iam_role_policy" "sqs_receive_policy" {
  name = "${var.lambda_function_name}-sqs-receive-policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Effect   = "Allow"
        Resource = aws_sqs_queue.event_queue.arn
      },
    ]
  })
}