# Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_administrator_access"></a> [administrator\_access](#module\_administrator\_access) | ./modules/permission-set | n/a |
| <a name="module_github-oidc"></a> [github-oidc](#module\_github-oidc) | ./modules/github-oidc | n/a |
| <a name="module_iam_user"></a> [iam\_user](#module\_iam\_user) | ./modules/iam-user | n/a |
| <a name="module_osac_terraform_state"></a> [osac\_terraform\_state](#module\_osac\_terraform\_state) | ./modules/bucket | n/a |
| <a name="module_route53_policy_innabox"></a> [route53\_policy\_innabox](#module\_route53\_policy\_innabox) | ./modules/iam-policy/route53-single-zone | n/a |
| <a name="module_route53_policy_ocp_massopen"></a> [route53\_policy\_ocp\_massopen](#module\_route53\_policy\_ocp\_massopen) | ./modules/iam-policy/route53-single-zone | n/a |
| <a name="module_route53_records"></a> [route53\_records](#module\_route53\_records) | ./modules/permission-set | n/a |
| <a name="module_view_only_access"></a> [view\_only\_access](#module\_view\_only\_access) | ./modules/permission-set | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.route53_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_identitystore_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) | resource |
| [aws_identitystore_group_membership.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group_membership) | resource |
| [aws_identitystore_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_user) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_iam_policy_document.route53_records](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | Primary AWS account ID | `string` | n/a | yes |
| <a name="input_aws_account_id_secondary"></a> [aws\_account\_id\_secondary](#input\_aws\_account\_id\_secondary) | Secondary AWS account ID | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_actions_admin_role_arn"></a> [github\_actions\_admin\_role\_arn](#output\_github\_actions\_admin\_role\_arn) | Set AWS\_ROLE\_ARN to this value for GitHub workflows that require administrative access |
| <a name="output_github_actions_dns_role_arn"></a> [github\_actions\_dns\_role\_arn](#output\_github\_actions\_dns\_role\_arn) | Set AWS\_ROLE\_ARN to this value for GitHub workflows that interact only with Route53 |
| <a name="output_iam_user_access_keys"></a> [iam\_user\_access\_keys](#output\_iam\_user\_access\_keys) | Show names, access key ids, and corresponding secret ARN for all managed iam users |
| <a name="output_identity_store_id"></a> [identity\_store\_id](#output\_identity\_store\_id) | ARN of the Identity Store instance associated with our IAM Identity Center instance. Used when creating SSO users and groups. |
| <a name="output_sso_instance_arn"></a> [sso\_instance\_arn](#output\_sso\_instance\_arn) | ARN of our AWS Identity Center instance |
<!-- END_TF_DOCS -->
