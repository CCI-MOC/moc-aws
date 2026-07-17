# Backblaze (b2)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_b2"></a> [b2](#requirement\_b2) | ~> 0.12 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bucket"></a> [bucket](#module\_bucket) | ./modules/bucket | n/a |
| <a name="module_key"></a> [key](#module\_key) | ./modules/application-key | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_b2_access_key"></a> [b2\_access\_key](#input\_b2\_access\_key) | Backblaze B2 application key ID | `string` | n/a | yes |
| <a name="input_b2_secret_key"></a> [b2\_secret\_key](#input\_b2\_secret\_key) | Backblaze B2 application key | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
