resource "aws_s3_bucket" "lambda_trigger_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "lambda_trigger_bucket_acl" {
  bucket = aws_s3_bucket.lambda_trigger_bucket.id
  acl    = "private"
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

  architectures = ["x86_64"]
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

  lambda_queue {
    lambda_function_arn = aws_lambda_function.s3_triggered_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
