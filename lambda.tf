# IAM Role for Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "lambda_ses_policy" {
  name        = "lambda_ses_policy"
  description = "Allows Lambda to send emails using SES"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ses:SendEmail"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "lambda_s3_policy"
  description = "Allows Lambda to read from S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "arn:aws:s3:::iti-alter-project/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ses_policy_attach" {
  policy_arn = aws_iam_policy.lambda_ses_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attach" {
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
  role       = aws_iam_role.iam_for_lambda.name
}

# Lambda Function
resource "aws_lambda_function" "ses_email_verifier" {
  filename         = "lambda.zip"
  function_name    = "ses_email_verifier"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda.lambda_handler"
  source_code_hash = filebase64sha256("lambda.zip")
  runtime          = "python3.13"

  environment {
    variables = {
      SES_EMAIL          = var.ses_email
      DESTINATION_EMAIL  = var.ses_email
    }
  }
}

# S3 Event Notification for Lambda
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "iti-alter-project"

  lambda_function {
    lambda_function_arn = aws_lambda_function.ses_email_verifier.arn
    events              = ["s3:ObjectCreated:*"]
  }
}
