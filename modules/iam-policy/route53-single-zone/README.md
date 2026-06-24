# Route53 Single Zone Policy

This creates an AWS IAM policy permitting Route53 access for a single zone. This is intended to support cert-manager on our OpenShift clusters. It permits both `ListHostedZones` and `ListHostedZonesByName` so that we can use zone names in addition to ids when configuring an Issuer.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_policy_name"></a> [policy\_name](#input\_policy\_name) | Name for the IAM policy | `string` | n/a | yes |
| <a name="input_zone_name"></a> [zone\_name](#input\_zone\_name) | Name of the Route53 hosted zone (e.g. example.com) | `string` | n/a | yes |
| <a name="input_policy_description"></a> [policy\_description](#input\_policy\_description) | Description for the IAM policy | `string` | `""` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_policy_arn"></a> [policy\_arn](#output\_policy\_arn) | n/a |
| <a name="output_zone_arn"></a> [zone\_arn](#output\_zone\_arn) | n/a |
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
<!-- END_TF_DOCS -->
