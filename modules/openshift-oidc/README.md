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
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.eso_secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.eso](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.service_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.eso_secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_iam_policy_document.cert_manager_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eso_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.eso_secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_account_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cert_manager_policy_arn"></a> [cert\_manager\_policy\_arn](#input\_cert\_manager\_policy\_arn) | ARN of the IAM policy granting Route53 access for cert-manager DNS-01 challenges | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Short identifier for the cluster, used in resource names and S3 path prefix (e.g., oac-infra, oac-staging) | `string` | n/a | yes |
| <a name="input_oidc_bucket_domain_name"></a> [oidc\_bucket\_domain\_name](#input\_oidc\_bucket\_domain\_name) | Regional domain name of the shared S3 bucket hosting OIDC discovery documents | `string` | n/a | yes |
| <a name="input_eso_writable_secret_prefixes"></a> [eso\_writable\_secret\_prefixes](#input\_eso\_writable\_secret\_prefixes) | List of Secrets Manager name prefixes that ESO is allowed to create (e.g. 'cluster/my-cluster/hostedcluster/') | `list(string)` | `[]` | no |
| <a name="input_service_account_roles"></a> [service\_account\_roles](#input\_service\_account\_roles) | Map of arbitrary Kubernetes service accounts to IAM roles. Each entry creates a web-identity role (assumable only by system:serviceaccount:<namespace>:<service\_account>) with the given policies attached. The map key is used in the role name. | <pre>map(object({<br/>    namespace       = string<br/>    service_account = string<br/>    policy_arns     = list(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cert_manager_role_arn"></a> [cert\_manager\_role\_arn](#output\_cert\_manager\_role\_arn) | ARN of the IAM role for cert-manager |
| <a name="output_eso_role_arn"></a> [eso\_role\_arn](#output\_eso\_role\_arn) | ARN of the IAM role for External Secrets Operator |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | OIDC issuer URL (the S3 path used as the cluster's serviceAccountIssuer) |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the Secrets Manager secret containing OIDC configuration |
| <a name="output_service_account_role_arns"></a> [service\_account\_role\_arns](#output\_service\_account\_role\_arns) | Map of service\_account\_roles keys to the ARN of the IAM role created for each |
<!-- END_TF_DOCS -->
