# 1. DynamoDB Table to store file metadata
resource "aws_dynamodb_table" "metadata_table" {
  name         = "S3MetadataTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "FileId"

  attribute {
    name = "FileId"
    type = "S"
  }
}

# 2. IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "S3LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic execution policy for CloudWatch logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach DynamoDB full access policy
resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# 3. Zip your Python code automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# 4. AWS Lambda Function
resource "aws_lambda_function" "s3_processor" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "S3EventProcessor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# 5. Reference your existing S3 bucket (or create a new one via Terraform)
# If you want Terraform to manage your existing bucket, replace 'sidu-awsproject-1' with your bucket name
variable "bucket_name" {
  default = "sidu-awsproject-1"
}

# Give S3 permission to invoke your Lambda function
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# 6. S3 Bucket Notification Trigger
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}