# VPC with Reserved CIDR, Additional Reserved CIDR for VPC, and Attach VPC to Transit Gateway Terraform Module

This Terraform module can provision three products from the AWS Service Catalog. The first module provisions a VPC with an optional secondary CIDR block, allowing you to enable Carrier-Grade NAT (CGNAT) for the secondary CIDR. The module can be customized to deploy a VPC with different subnet layouts, including an empty VPC or VPCs with both private and public subnets. It supports enabling or disabling CGNAT with configurable parameters for CIDR size and subnet layout.

The second module adds reserved CIDR to an existing VPC.

The third module attaches the specified VPC to the regional transit gateway and provides routing to both the central services and the VPN connected to the local data center.

Let's consider the following AWS Service Catalog products as A, B, and C:

- **A**: vpc-base-with-reserved-cidr - User wants to create a VPC with reserved CIDR.
- **B**: vpc-add-reserved-cidr - User already has a VPC and wants to reserve CIDR for it.
- **C**: Attach VPC to Transit Gateway - User wants to connect the VPC to the Transit Gateway.

This repository has the capability to launch these products individually or in combination as follows:

1. A
2. A + C
3. B
4. B + C
5. C

<!-- toc -->

## Table of Contents

- [Introduction](#introduction)
- [Example Use Case](#example-use-case)
- [Telemetry Tags](#telemetry-tags)
    - [Telemetry Tags Configuration](#telemetry-tags-configuration)
- [Limitations](#limitations)
- [Requirements](#requirements)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

<!-- tocstop -->

## A: vpc-base-with-reserved-cidr

**User Scenario**: User already has a VPC and wants to reserve CIDR for it.

This module allows the creation of a VPC with an optional secondary CIDR block. By default, the secondary CIDR block does not enable CGNAT. If enabled, CGNAT will use a non-routable CIDR block of `100.64.0.0/16` for the secondary CIDR.

Below are the parameters that must be passed for this module:

### VpcSize
- **Allowed Values**: 24, 25, 26  
  The subnet mask for the VPC CIDR block. A value of 24 will reserve a CIDR block with 256 IP addresses. Entering 25 will reserve 128 IP addresses, and 26 will reserve 64 IP addresses. Please be careful while selecting the CIDR block as we are running out of CIDR blocks. If you don't need a large CIDR block, consider using a smaller CIDR block or adding a secondary non-routable CIDR below.

### VpcDescription
- A brief description of this VPC.

### SubnetLayout
- **Allowed Values**: Empty, PrivatePublic, Private  
  Type of configuration:
  - **Empty**: Creates an empty VPC.
  - **PrivatePublic**: Creates a VPC with 2 public and 2 private subnets and an internet gateway.
  - **Private**: Creates only a VPC with 2 private subnets.

### EnableCGNat
- **Allowed Values**: Yes, No  
  Add a non-routable CGNAT CIDR of `100.64.0.0/x` to the primary VPC. This is not routable to on-premises but is suitable for high IP usage workloads such as EKS.

### CGNatCIDR
- CIDR size. Can be between `100.64.0.0/16` and `100.64.0.0/28`  
  - **Default**: 16  
  - **Min Value**: 16  
  - **Max Value**: 28  

## B: vpc-add-reserved-cidr

**User Scenario**: User already has a VPC and wants to reserve CIDR for it.

This module adds reserved CIDR to your existing VPC.

Below are the parameters that must be passed for this module:

### CidrBlock
- **Allowed Values**: 24, 25, 26  

### CidrBlockDescription
- A brief description of the VPC.

### VPC
- **Id**: The ID of the existing VPC.

## C: Attach VPC to Transit Gateway

**User Scenario**: User wants to connect the VPC to the Transit Gateway.

This module attaches the specified VPC to the regional transit gateway and provides routing to both the central services and the VPN connected to the local data center. Central services should eventually include things like Mulesoft, Ocelot, and Managed AD. Documentation about data centers can be found at "https://docs.int.bayer.com/cloud/smart-aws/smart-2.0/datacenter/". If you use this on a VPC that is already connected to the Transit VPC, it will disrupt existing connections. You'll need to request changes from the firewall team before your hosts can connect to hosts located in the local data center.

Below are the parameters that must be passed for this module:

### VpcId
- The ID of the VPC to attach to the Transit Gateway.

### SubnetIds
- IDs of the private subnets to attach to the Transit Gateway (pick one per AZ).

## A + C and B + C: Create Resources in Combination

- **A + C**: Create a new VPC with reserved CIDR and attach this VPC to the Transit Gateway.
- **B + C**: Add new reserved CIDR and attach the Transit Gateway to an existing VPC.

## Example Use Case

### Basic Example:

```hcl
module "vpc_with_cidr" {
  source          = "../.."
  description     = "Create VPC with Reserved CIDR and Secondary CIDR"
  size            = 25
  subnet_layout   = "Private"
  enable_cgnat    = true
  cgnat_cidr_size = 16
  create_vpc      = true
  reserve_cidr    = true
  region          = "eu-central-1"
}

Advance Example :

```hcl
module "vpc_cidr_tgw" {
  source          = "path/to/module"
  description     = "Create VPC with Reserved CIDR and Secondary CIDR. Also Attach Transit Gateway"
  size            = 26
  subnet_layout   = "Private"
  enable_cgnat    = true
  cgnat_cidr_size = 16
  create_vpc      = true
  reserve_cidr    = true
  attach_tgw      = true
  region          = "eu-central-1"
}

```
## Telemetry Tags

The module must include telemetry tags that provide important metadata and tracking information for resources created by the module. These tags help to identify the source, version, and stage of deployment of the module. It is essential not to forget to add these telemetry tags as default tags to all resources created by the module.

### Telemetry Tags Configuration

The module defines the `telemetry_tags` local variable, which consists of the following tags:

- `ModuleSource`: Specifies the source of the module. By default it is set to "SCA". Please replace this with the name of your team.
- `ModuleProject`: Represents the name of your project. Replace `<project-name>` with the module repo name.
- `ModuleVersion`: Specifies the version of the module. Please refer to the [Module versioning](#module-versioning) section for the detailed information.
- `ModuleStage`: Indicates the stage of deployment for the module. It is recommended to replace `<deployment-id>` with the `stage` variable defined within your module.

To ensure that the telemetry tags are added as default tags for all resources created by the module, make sure to include the necessary code or configuration logic that attaches these tags to the resources appropriately.

# Folder Structure

Here is a folder structure for your Terraform configuration that you might want to follow:

* main.tf: This is the entry point of your configuration where you typically import modules or define core resources.
* variables.tf: Contains all variable definitions for your project.
* outputs.tf: Declares the outputs that you want to be returned after applying the Terraform plan.
* examples/: A folder for various examples:
* complete/: Contains fully configured setups with complete parameters, representing a production-ready or full deployment example.
* basic/: Simpler, minimal setup examples that could be used for smaller deployments or testing.


## Limitations

* The secondarycidr_cgnat_cidr must be between 100.64.0.0/16 and 100.64.0.0/28.
* Ensure that the selected CIDR sizes meet your IP address requirements.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.58.0, < 6.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |
## Resources

| Name | Type |
|------|------|
| [aws_servicecatalog_provisioned_product.vpc_add_reserved_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_provisioned_product) | resource |
| [aws_servicecatalog_provisioned_product.vpc_base_with_reserved_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_provisioned_product) | resource |
| [aws_servicecatalog_provisioned_product.vpc_tgw_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/servicecatalog_provisioned_product) | resource |
| [null_resource.add_cidr_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.vpc_id_validation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_id.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_servicecatalog_provisioning_artifacts.vpc_add_reserved_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicecatalog_provisioning_artifacts) | data source |
| [aws_servicecatalog_provisioning_artifacts.vpc_base_with_reserved_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicecatalog_provisioning_artifacts) | data source |
| [aws_servicecatalog_provisioning_artifacts.vpc_tgw_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/servicecatalog_provisioning_artifacts) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attach_tgw"></a> [attach\_tgw](#input\_attach\_tgw) | Flag to determine to attach VPC to Transit Gateway. | `bool` | `false` | no |
| <a name="input_cgnat_cidr_size"></a> [cgnat\_cidr\_size](#input\_cgnat\_cidr\_size) | CIDR size. Can be between 100.64.0.0/16 & 100.64.0.0/28 | `number` | `16` | no |
| <a name="input_cidr_product_version"></a> [cidr\_product\_version](#input\_cidr\_product\_version) | The version of the module to deploy CIDR for VPC. | `string` | `null` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Flag to determine whether to create a new VPC Base Reserverd CIDR. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | A user-defined description, Must be a non-empty string. | `string` | `"Default Description"` | no |
| <a name="input_enable_cgnat"></a> [enable\_cgnat](#input\_enable\_cgnat) | A flag that enables or disables Carrier-Grade NAT (CGNAT) for the CIDR block. Add a non-routable CGNAT CIDR of 100.64.0.0/x to the primary VPC. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy resources. | `string` | `"eu-central-1"` | no |
| <a name="input_reserve_cidr"></a> [reserve\_cidr](#input\_reserve\_cidr) | Flag to determine to create add CIDR to an existing VPC. | `bool` | `true` | no |
| <a name="input_size"></a> [size](#input\_size) | The subnet mask for the VPC CIDR block. A value of 24 will reserve a CIDR block with 256 IP addresses. Entering 25 will reserve 128 IP addresses, 26 half as many (64) | `number` | `26` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to be used. | `list(string)` | `[]` | no |
| <a name="input_subnet_layout"></a> [subnet\_layout](#input\_subnet\_layout) | Type of configuration: 'Empty': creates an empty VPC, 'PrivatePublic': creates a VPC with 2 public and 2 private subnets and an internet gateway, 'Private' creates only a VPC with 2 private subnets. | `string` | `"Empty"` | no |
| <a name="input_tgw_product_version"></a> [tgw\_product\_version](#input\_tgw\_product\_version) | The version of the module to deploy Attach VPC to Transit Gateway. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The Id of the existing VPC. | `string` | `""` | no |
| <a name="input_vpc_product_version"></a> [vpc\_product\_version](#input\_vpc\_product\_version) | The version of the modue to deploy for VPC Base with CIDR. | `string` | `null` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_route_table_1"></a> [private\_route\_table\_1](#output\_private\_route\_table\_1) | Private Route Table 1 |
| <a name="output_private_route_table_2"></a> [private\_route\_table\_2](#output\_private\_route\_table\_2) | Private Route Table 2 |
| <a name="output_private_subnet_1"></a> [private\_subnet\_1](#output\_private\_subnet\_1) | Private Subnet 1 |
| <a name="output_private_subnet_2"></a> [private\_subnet\_2](#output\_private\_subnet\_2) | Private Subnet 2 |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | The CIDR range for the overall VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC Info |
| <a name="output_vpc_id_validation_error"></a> [vpc\_id\_validation\_error](#output\_vpc\_id\_validation\_error) | Shows whether vpc\_id validation passed |
<!-- END_TF_DOCS -->
