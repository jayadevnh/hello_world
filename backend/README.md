---
title: SCA Terraform Modules
---

This page contains the list of modules and templates provided by SMART Cloud Automation
team. The modules are designed to be used in SMART environments and provide compliance
with Bayer guidelines and best practices. You can also browse the modules on
[GitHub](https://github.com/search?q=topic%3Aterraform-module+topic%3Asmart-cloud-automation+org%3Abayer-int+fork%3Atrue&type=repositories).

See the guidelines for contributing in the Terraform module
template [repository](https://github.com/bayer-int/smart-terraform-module-template) if
you want to contribute some changes to existing modules or propose a new module to this
catalog.

## Azure

| Name                  | Module                                                                                    | Description                                                                                                                                                           |
| --------------------- | ----------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Virtual Machine (VM) | [bayer-int/smart-azure-vm-terraform](https://github.com/bayer-int/smart-azure-vm-terraform) | A Terraform module for provisioning new Virtual Machines in the owner's account. The IaC can deploy Linux and Windows Machines running Tanium and Crowstrike on them. |
| API Management | [bayer-int/smart-azure-api-gateway-terraform](https://github.com/bayer-int/smart-azure-api-gateway-terraform) | A Terraform module for provisioning Azure API Management service with one of more APIs configured. In addition it allows to publish your API specification and documentation to AnyPoint Exchange Catalog. |
| Virtual Network (VNet) | [bayer-int/smart-azure-vnet-terraform](https://github.com/bayer-int/smart-azure-vnet-terraform) | A Terraform module that deploys a Virtual Network in Azure with a subnet or a set of subnets passed in as input parameters. |
| Backup Service | [bayer-int/smart-azure-backup-terraform](https://github.com/bayer-int/smart-azure-backup-terraform) | A Terraform module that deploys Azure Recovery Services Vault with an Azure Policy for easy enrollment of VMs into backup. |
| Microsoft SQL Server | [bayer-int/smart-azure-mssql-db-terraform](https://github.com/bayer-int/smart-azure-mssql-db-terraform) | A Terraform module for deploying and managing Microsoft SQL Server (MSSQL) databases in Azure |
| PostgreSQL Server | [bayer-int/smart-azure-postgresql-db-terraform](https://github.com/bayer-int/smart-azure-postgresql-db-terraform) | A Terraform module for deploying and managing PostgreSQL Flexible Server databases in Azure |
| MySQL Server | [bayer-int/smart-azure-mysql-db-terraform](https://github.com/bayer-int/smart-azure-mysql-db-terraform) | A Terraform module for deploying and managing MySQL Flexible Server databases in Azure |
| Key Vault | [bayer-int/smart-azure-key-vault-terraform](https://github.com/bayer-int/smart-azure-key-vault-terraform) | A Terraform module for deploying and managing Key Vault in Azure |

## AWS

| Name                  | Module                                                                                | Description                                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Virtual Machine (EC2 instance) | [bayer-int/smart-aws-vm-terraform](https://github.com/bayer-int/smart-aws-vm-terraform) | A Terraform module for provisioning new Virtual Machines in the owner's account. The IaC can deploy Linux and Windows Machines running Tanium and Crowstrike on them. |
| API Gateway | [bayer-int/smart-aws-api-gateway-http-terraform](https://github.com/bayer-int/smart-aws-api-gateway-http-terraform) | A Terraform module for provisioning AWS API Gateway service with one of more APIs configured. In addition it allows to publish your API specification and documentation to AnyPoint Exchange Catalog. |
| Virtual Private Cloud (VPC) | [bayer-int/smart-aws-vpc-terraform](https://github.com/bayer-int/smart-aws-vpc-terraform) | A Terraform module that creates a Virtual Private Cloud (VPC) in AWS with configurable subnets and additional resources. |
| S3 bucket | [bayer-int/smart-aws-s3-bucket-terraform](https://github.com/bayer-int/smart-aws-s3-bucket-terraform) | A Terraform module that provisions an AWS S3 bucket while also handling the management and configuration of different features associated with it. |
| [ECS Cluster](./ecs.md) | [bayer-int/smart-aws-ecs-terraform](https://github.com/bayer-int/smart-aws-ecs-terraform) | A Terraform module to create ESC cluster and build applications. Clusters and Applications can be deployed apart. There is compatibility with [fg-deploy](../../smart-aws/kb/how-to/fargate.md) |
| OIDC Provider | [bayer-int/smart-aws-github-oidc-provider](https://github.com/bayer-int/smart-aws-github-oidc-provider). | A Terraform module that provisions an AWS Service Catalog product with predefined parameters. |
| EKS OIDC Provider | [bayer-int/smart-aws-eks-oidc-provider](https://github.com/bayer-int/smart-aws-eks-oidc-provider). | A Terraform module that provisions an AWS Service Catalog Product with EKS Cluster and VPC as predefined parameters. |
| VPC, Additional CIDR and TGW | [bayer-int/smart-aws-bayer-vpc-products-terraform](https://github.com/bayer-int/smart-aws-bayer-vpc-products-terraform). | A Terraform module for provisioning AWS Service Catalog Products. VPC with Reserved and Secondary CIDR, add CIDR to Existing VPC, and attach Transit Gateway to VPC. Also can deploy products in combination with predefined parameters. |

## Google Cloud Platform

| Name                  | Module                                                                                | Description                                                                                                                                                           |
| --------------------- | ------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| WAF Rules | [bayer-int/smart-gcp-waf-baseline](https://github.com/bayer-int/smart-gcp-waf-baseline/) | Terraform module to create a set of Web ACLs [mandated](https://bayergroup.sharepoint.com/:w:/r/sites/CloudDevOpsInfrastructureSecurityProject/Shared%20Documents/General/2023/Execution/WAF%20and%20Container%20Security/WAF%20Strategy%20and%20Overview.docx?d=w8ba8f4c5387d4679b86f55c181816f53&csf=1&web=1&e=i2D9Mf) by CSRM in your GCP project. |
| API Gateway | [bayer-int/smart-gcp-api-gateway-terraform](https://github.com/bayer-int/smart-gcp-api-gateway-terraform) | A Terraform module for provisioning GCP API Gateway service with an OpenAPI configuration. In addition it allows to publish your API specification and documentation to AnyPoint Exchange Catalog. |
| Virtual Private Cloud (VPC) | [bayer-int/smart-gcp-vpc-terraform](https://github.com/bayer-int/smart-gcp-vpc-terraform) | A Terraform module that creates a Virtual Private Cloud (VPC) in GCP with configurable subnets and additional resources. |
| Service Account role assignment | [bayer-int/smart-gcp-sa-roles-terraform](https://github.com/bayer-int/smart-gcp-sa-roles-terraform) | A Terraform module for assigning roles to Service Account for deployment in Google Cloud |
