# Backblaze (b2) bucket

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_b2"></a> [b2](#provider\_b2) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [b2_bucket.this](https://registry.terraform.io/providers/Backblaze/b2/latest/docs/resources/bucket) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the B2 bucket | `string` | n/a | yes |
| <a name="input_bucket_type"></a> [bucket\_type](#input\_bucket\_type) | Bucket type (allPrivate or allPublic) | `string` | `"allPrivate"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_id"></a> [id](#output\_id) | The ID of the bucket |
| <a name="output_name"></a> [name](#output\_name) | The name of the bucket |
<!-- END_TF_DOCS -->
