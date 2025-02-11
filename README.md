Here's a sample `README.md` file that outlines how to use the provided Terraform configuration, including details on setting up authentication using OpenID Connect (OIDC) from GitHub to AWS and integrating GitHub Actions for CI/CD. 

```markdown
# Terraform AWS Infrastructure

This repository contains a Terraform configuration to set up an AWS infrastructure that includes:
- An Amazon ECR repository for Docker images
- An AWS Lambda function using a Docker image
- An API Gateway to expose the Lambda function
- An Amazon Cognito User Pool for user authentication
- GitHub OIDC for authentication to AWS

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- Docker installed and running
- A GitHub repository for CI/CD

## Variables

Make sure to define the following variables in a `variables.tf` file or directly in the Terraform configuration:

```hcl
variable "region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  default     = 30
}

variable "domain_name" {
  description = "Cognito User Pool domain name"
  default     = "my-cognito-domain"
}
```

## Setup Instructions

1. Clone this repository to your local machine.

    ```bash
    git clone <repository-url>
    cd <repository-directory>
    ```

2. Initialize Terraform.

    ```bash
    terraform init
    ```

3. Plan the deployment.

    ```bash
    terraform plan
    ```

4. Apply the configuration to create the resources.

    ```bash
    terraform apply
    ```

5. Confirm the changes by typing `yes` when prompted.

## Authentication Using OIDC from GitHub

To enable authentication using OpenID Connect (OIDC) from GitHub to AWS, follow these steps:

### Create a GitHub OIDC Provider in AWS

1. Go to the IAM console in AWS.
2. Under "Identity providers", choose "Add provider".
3. For Provider Type, choose "OpenID Connect".
4. For Provider URL, enter `https://token.actions.githubusercontent.com`.
5. For Audience, enter `sts.amazonaws.com`.

### Create an IAM Role for GitHub Actions

1. Create a new IAM role with the following trust relationship policy:

    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Federated": "arn:aws:iam::<your_account_id>:oidc-provider/token.actions.githubusercontent.com"
          },
          "Action": "sts:AssumeRoleWithWebIdentity",
          "Condition": {
            "StringEquals": {
              "token.actions.githubusercontent.com:sub": "repo:<owner>/<repo>:ref:refs/heads/<branch>"
            }
          }
        }
      ]
    }
    ```

2. Attach necessary policies to the role to allow it to interact with AWS services (e.g., Lambda execution permissions).

### GitHub Actions Configuration

Create a `.github/workflows/ci.yml` file in your GitHub repository:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.0.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        run: terraform apply -auto-approve
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_REGION: us-east-1
```

Make sure to add your AWS credentials as secrets in your GitHub repository (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`).

## Cleanup

To remove all resources created by Terraform, run:

```bash
terraform destroy
```

Confirm the changes by typing `yes` when prompted.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Terraform](https://www.terraform.io/)
- [AWS](https://aws.amazon.com/)
- [GitHub Actions](https://docs.github.com/en/actions)
```

Feel free to adjust the content and instructions as necessary to fit your project's needs. If you have any specific changes or additions you'd like to make, let me know!