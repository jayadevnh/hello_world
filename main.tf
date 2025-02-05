provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

resource "aws_ecr_repository" "my_ecr_repo" {
  name = "my-app-repo" # Replace with your repository name

  image_tag_mutability = "MUTABLE" # Options: MUTABLE or IMMUTABLE
  force_delete         = true
  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_ecr_authorization_token" "ecr_token" {}

resource "null_resource" "build_and_push_docker_image" {
  provisioner "local-exec" {
    command = <<EOT
    # Authenticate Docker to AWS ECR
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.my_ecr_repo.repository_url}
    
    # Build Docker Image
    docker build -t ${aws_ecr_repository.my_ecr_repo.repository_url}:latest .

    # Push Docker Image to ECR
    docker push ${aws_ecr_repository.my_ecr_repo.repository_url}:latest
    EOT
  }
}

# Lambda Function Role
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda Function Using Container Image
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my-container-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.my_ecr_repo.repository_url}:latest"
  timeout       = 10
  
  depends_on = [null_resource.build_and_push_docker_image]
}

# Create API Gateway HTTP API
resource "aws_apigatewayv2_api" "my_http_api" {
  name          = "my-http-api"
  protocol_type = "HTTP"
}

# Create an integration for the Lambda function
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.my_http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.my_lambda_function.arn
  payload_format_version = "2.0"
}

# Create a route for the API
resource "aws_apigatewayv2_route" "my_route" {
  api_id    = aws_apigatewayv2_api.my_http_api.id
  route_key = "ANY /helloworld" # Change "/helloworld" to your desired path
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Create stage for the API
resource "aws_apigatewayv2_stage" "my_stage" {
  api_id      = aws_apigatewayv2_api.my_http_api.id
  name        = "v1" # Change this to your desired stage name
  auto_deploy = true
}

# Grant API Gateway permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  # The source ARN is the API Gateway's ARN
  source_arn = "${aws_apigatewayv2_api.my_http_api.execution_arn}/*/*"
}

output "repository_url" {
  description = "The URL of the ECR repository."
  value       = aws_ecr_repository.my_ecr_repo.repository_url
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda_function.function_name
}

output "api_endpoint" {
  description = "The endpoint of the API Gateway."
  value       = "${aws_apigatewayv2_api.my_http_api.api_endpoint}/v1/helloworld" # Change "/helloworld" to match your route
}