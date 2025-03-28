provider "aws" {
  region = var.region
}

########## State File Backend S3 ##########

# Configure the S3 backend
terraform {
  backend "s3" {
    bucket = "hello-world-tf-state-820242915362"
    key    = "terraform.tfstate"
    region = "us-east-1" # Change this to your desired region
  }
}

########## ECR Repo and Docker Image ##########

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
  triggers = {
    index_js_hash = filemd5("./backend/index.js")
  }
  provisioner "local-exec" {
    command = <<EOT
    # Authenticate Docker to AWS ECR
    aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.my_ecr_repo.repository_url}
    
    # Build Docker Image
    docker build -t ${aws_ecr_repository.my_ecr_repo.repository_url}:latest ./backend

    # Push Docker Image to ECR
    docker push ${aws_ecr_repository.my_ecr_repo.repository_url}:latest
    EOT
  }
}

########## LAMBDA FUNCTION ##########

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

data "aws_ecr_image" "my_ecr_image" {
  repository_name = aws_ecr_repository.my_ecr_repo.name
  image_tag       = "latest"
  depends_on      = [null_resource.build_and_push_docker_image]
}

# Create Lambda Function Using Container Image
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my-container-lambda"
  role          = aws_iam_role.lambda_exec_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.my_ecr_repo.repository_url}@${data.aws_ecr_image.my_ecr_image.image_digest}"
  timeout       = var.lambda_timeout

  depends_on = [null_resource.build_and_push_docker_image]
}

########## API GATEWAY ##########

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

# Create route with Cognito JWT Authorizer
resource "aws_apigatewayv2_route" "my_route" {
  api_id    = aws_apigatewayv2_api.my_http_api.id
  route_key = "ANY /helloworld"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"

  # Attach JWT Authorizer
  authorizer_id      = aws_apigatewayv2_authorizer.cognito_authorizer.id
  authorization_type = "JWT"
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

########## COGNITO ##########

# Cognito User Pool
resource "aws_cognito_user_pool" "my_user_pool" {
  name                     = "my-user-pool"
  alias_attributes         = ["email", "phone_number", "preferred_username"]
  auto_verified_attributes = ["email"]

  # Required attributes for sign-up
  schema {
    name                = "email"
    required            = true
    attribute_data_type = "String"
  }
}

# Cognito App Client
resource "aws_cognito_user_pool_client" "my_user_pool_client" {
  name                                 = "my-app-client"
  user_pool_id                         = aws_cognito_user_pool.my_user_pool.id
  allowed_oauth_flows                  = ["implicit"]
  explicit_auth_flows                  = ["ALLOW_USER_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
  generate_secret                      = true
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  callback_urls                        = ["${aws_apigatewayv2_api.my_http_api.api_endpoint}/v1/helloworld"] # Change to your API endpoint
  supported_identity_providers         = ["COGNITO"]
  prevent_user_existence_errors        = "ENABLED"
  allowed_oauth_flows_user_pool_client = true
}

# Cognit Domain
resource "aws_cognito_user_pool_domain" "my_user_pool_domain" {
  domain       = var.domain_name
  user_pool_id = aws_cognito_user_pool.my_user_pool.id
}

########## JWT Token Authorizer ##########

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id           = aws_apigatewayv2_api.my_http_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "CognitoAuthorizer"
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.my_user_pool_client.id]
    issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}"
  }

  depends_on = [aws_cognito_user_pool_client.my_user_pool_client]
}
