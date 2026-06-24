# Bucket

Manage AWS S3 buckets.

## Example usage

To create a simple bucket:

```hcl
module "example_bucket" {
  source = "./modules/bucket"
  name   = "example-bucket"
}
```

To create Glacier Flexible Retrieval bucket:

```hcl
module "example_bucket" {
  source        = "./modules/bucket"
  name          = "example-bucket"
  storage_class = "GLACIER"
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
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | When false, block all public access to the bucket | `bool` | `false` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | S3 storage class for lifecycle transition (e.g. GLACIER, GLACIER\_IR, STANDARD\_IA, DEEP\_ARCHIVE). When null, no lifecycle rule is created. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket |
| <a name="output_id"></a> [id](#output\_id) | The name of the bucket |
<!-- END_TF_DOCS -->
