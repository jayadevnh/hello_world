# Attach VPC to Transit Gateway Example

Advanced usage of the module demonstrating more complex use cases.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.20.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_complete_vpc"></a> [vpc\_tgw\_attach](#module\_complete\_vpc) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_product_version"></a> [product\_version](#input\_product\_version) | The version of the module to deploy. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy resources. | `string` | `"eu-central-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `"vpc-0dd1c26ad7ba8cc5f"` | no |
| <a name="input_subnet_ids"></a> [subnet\_id](#input\_vpc\_id) | Private Subnet IDs | `string` | `"subnet-0968ae4ed263f8177"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_vpc\_id) | Private Subnet IDs | `list(string)` | `["subnet-0968ae4ed263f8177", "subnet-1234abcd5678efgh", "subnet-8765efgh4321abcd"]` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
