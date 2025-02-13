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

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool."
  value       = aws_cognito_user_pool.my_user_pool.id
}

output "cognito_app_client_id" {
  description = "The ID of the Cognito App Client."
  value       = aws_cognito_user_pool_client.my_user_pool_client.id
}

output "cognito_domain" {
  description = "The domain for the Cognito User Pool."
  value       = aws_cognito_user_pool_domain.my_user_pool_domain.domain
}

output "cognito_issuer_url" {
  value = "https://cognito-idp.us-east-1.amazonaws.com/${aws_cognito_user_pool.my_user_pool.id}"
}

output "cognito_hosted_ui_login_url" {
  value       = "https://${aws_cognito_user_pool_domain.my_user_pool_domain.domain}.auth.${var.region}.amazoncognito.com/login"
  description = "URL for the Cognito Hosted UI login page"
}