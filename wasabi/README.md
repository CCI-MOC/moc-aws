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
| <a name="provider_aws.wasabi"></a> [aws.wasabi](#provider\_aws.wasabi) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_group.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group) | resource |
| [aws_iam_group_membership.admins](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_membership) | resource |
| [aws_iam_group_policy_attachment.admins_administrator_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_user.lars](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.nerc_backup_wasabi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user.tschwesi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_s3_bucket.nerc_loki_backup_bu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.nerc_metrics_backup_bu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_wasabi_access_key"></a> [wasabi\_access\_key](#input\_wasabi\_access\_key) | Wasabi access key | `string` | n/a | yes |
| <a name="input_wasabi_secret_key"></a> [wasabi\_secret\_key](#input\_wasabi\_secret\_key) | Wasabi secret key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
