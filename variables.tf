# variables.tf

variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "domain_name" {
  description = "The domain name for the Cognito user pool"
  type        = string
  default     = "my-app-domain-hw"
}