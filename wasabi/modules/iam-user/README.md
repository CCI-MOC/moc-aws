# Wasabi IAM User

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_aws.secrets"></a> [aws.secrets](#provider\_aws.secrets) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_login_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_login_profile) | resource |
| [aws_iam_user_policy_attachment.change_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_iam_user_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_secretsmanager_secret.console_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.console_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM user | `string` | n/a | yes |
| <a name="input_allow_change_password"></a> [allow\_change\_password](#input\_allow\_change\_password) | Whether to attach the IAMUserChangePassword policy to the user | `bool` | `false` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | List of additional policy ARNs to attach to the user | `list(string)` | `[]` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion) | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_console_secret"></a> [console\_secret](#output\_console\_secret) | Secrets Manager secret containing the initial console password |
| <a name="output_name"></a> [name](#output\_name) | The IAM user name |
<!-- END_TF_DOCS -->
