# IAM User

Manage AWS IAM users.

## Access keys

Request access keys by providing a label=description map to the `access_keys` parameter. When keys are created, information about the key (the generated key id and secret) will be stored in AWS Secrets Manager, at the path `iam-user/USERNAME/LABEL`.

## Example usage

```hcl
module "iam_user_example" {
  source      = "./modules/iam-user"
  name        = example
  access_keys = {
    my-access-key = "An access key for testing things"
  }
  policy_arns = {
    example-policy = arn:aws:iam::012345678901:policy/example-policy
  }
  tags = {
    example-tag = example-value
  }
}
```

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
| [aws_iam_access_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |
| [aws_secretsmanager_secret.access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the IAM user | `string` | n/a | yes |
| <a name="input_access_keys"></a> [access\_keys](#input\_access\_keys) | Map of access key labels to descriptions | `map(string)` | `{}` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | Map of managed policy ARNs to attach to the user (key = stable name, value = ARN) | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the IAM user | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_access_keys"></a> [access\_keys](#output\_access\_keys) | n/a |
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
| <a name="output_name"></a> [name](#output\_name) | n/a |
<!-- END_TF_DOCS -->
