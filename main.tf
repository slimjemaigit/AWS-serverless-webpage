provider "aws" {
  region = var.aws_region
}

##### create lambda function #####

#defining an AWS IAM policy document that allows a Lambda function to assume a role
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

#defining an AWS IAM role specifically for the Lambda function
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

#defining the lambda function file and archive
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "D:/Slim-Jemai/personal/aws-project/lambda-function/lambda_function.py"
  output_path = "D:/Slim-Jemai/personal/aws-project/lambda-function/lambda_function.zip"
}

#creating the Lambda function
resource "aws_lambda_function" "test_lambda" {

  filename      = "D:/Slim-Jemai/personal/aws-project/lambda-function/lambda_function.zip"
  function_name = "lambda_function"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.8"

}

##### create API Gateway #####

#configure the root "REST API" object
resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "test-lambda"
  description = "Terraform Serverless Application Example"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Define API Gateway Resource
resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "example"
}

# Define API Gateway Method
resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = "GET"
  authorization = "NONE"
}

# Define API Gateway Integration
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.gateway_resource.id
  http_method             = aws_api_gateway_method.lambda_method.http_method
  integration_http_method = "GET"  # Or use "GET" if appropriate
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
}

# Create Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*" 
}  


#deployment stage
resource "aws_api_gateway_deployment" "dev_deployment" {
  depends_on = [
    "aws_api_gateway_integration.lambda_integration"
  ]
  rest_api_id = "${aws_api_gateway_rest_api.lambda_api.id}"
  stage_name  = "dev"
}

# Output deployment stage invoke URL
output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.dev_deployment.invoke_url
} 


##### create S3 bucket #####
resource "aws_s3_bucket" "project_bucket" {
  bucket = "project-bucket-for-lambda"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_owner" {
  bucket = aws_s3_bucket.project_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_owner,
    aws_s3_bucket_public_access_block.s3_access,
  ]

  bucket = aws_s3_bucket.project_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.project_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.project_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.project_bucket.arn}/*"
        ]
      }
    ]
  })
} 

#creating cloud watch 
resource "aws_cloudwatch_log_group" "lambda_cloudwatch_log" {
  name              = "/aws/lambda/${aws_lambda_function.test_lambda.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/apigateway/api-for-lambda"
  retention_in_days = 7
}