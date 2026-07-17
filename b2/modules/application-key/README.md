# Backblaze (b2) application keys

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_b2"></a> [b2](#provider\_b2) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [b2_application_key.this](https://registry.terraform.io/providers/Backblaze/b2/latest/docs/resources/application_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_capabilities"></a> [capabilities](#input\_capabilities) | List of capabilities granted to the key | `set(string)` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | Name for the application key | `string` | n/a | yes |
| <a name="input_bucket_ids"></a> [bucket\_ids](#input\_bucket\_ids) | Restrict the key to specific buckets | `set(string)` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the Secrets Manager secret | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Restrict access to files with this prefix | `string` | `null` | no |
| <a name="input_secret_recovery_window_in_days"></a> [secret\_recovery\_window\_in\_days](#input\_secret\_recovery\_window\_in\_days) | Number of days that AWS Secrets Manager waits before deleting a secret (0 for immediate deletion) | `number` | `30` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_application_key_id"></a> [application\_key\_id](#output\_application\_key\_id) | The application key ID |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the Secrets Manager secret containing the key |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the Secrets Manager secret containing the key |
<!-- END_TF_DOCS -->
