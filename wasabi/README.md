# Wasabi

We are using [Wasabi] (for cost reasons) to backup data from the NERC monitoring environment. This module manages our Wasabi resources (users, groups, policies, buckets, etc). Note that we don't have a clever solution here (yet) for managing access key secrets like we do for AWS users; this can be added in the future if we make further use of this service.

[wasabi]: https://wasabi.com/

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_aws.wasabi"></a> [aws.wasabi](#provider\_aws.wasabi) | ~> 5.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bucket"></a> [bucket](#module\_bucket) | ./modules/bucket | n/a |
| <a name="module_user"></a> [user](#module\_user) | ./modules/iam-user | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_group.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy_attachment.admins_administrator_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.nerc_wasabi_backup_write_no_delete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.nerc_wasabi_backup_write_no_delete](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_wasabi_access_key"></a> [wasabi\_access\_key](#input\_wasabi\_access\_key) | Wasabi access key | `string` | n/a | yes |
| <a name="input_wasabi_secret_key"></a> [wasabi\_secret\_key](#input\_wasabi\_secret\_key) | Wasabi secret key | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_user_passwords"></a> [user\_passwords](#output\_user\_passwords) | Initial console passwords for Wasabi users with login profiles |
<!-- END_TF_DOCS -->
