# GitHub OIDC

Manage policies to permit GitHub workflows to authenticate against AWS. For more information, see:

- From GitHub: [Configuring OpenID Connect in Amazon Web Services][github-oidc]
- From AWS: [Use IAM roles to connect GitHub Actions to actions in AWS][aws-oidc]

## Example usage

To create the policies:

```hcl
module "github-oidc" {
  source         = "./modules/github-oidc"
  dns_policy_arn = aws_iam_policy.route53_records.arn
}
```

To configure a GitHub workflow to authenticate against AWS, create a secret `AWS_ROLE_ARN` using the value of one of the role ARNs output by this module:

```sh
gh secret set AWS_ROLE_ARN -b arn:aws:iam::012345678901:role/github-actions-dns
```

And then in your workflow use `aws-actions/configure-aws-credentials` to acquire credentials:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    aws-region: us-east-1
```

[github-oidc]: https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-aws
[aws-oidc]: https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/

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
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github_actions_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.github_actions_admin_deny_dangerous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.github_actions_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_actions_dns_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.github_actions_admin_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_admin_deny_dangerous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_dns_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_policy_arn"></a> [dns\_policy\_arn](#input\_dns\_policy\_arn) | ARN of the managed IAM policy for Route53 record management | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_actions_admin_role_arn"></a> [github\_actions\_admin\_role\_arn](#output\_github\_actions\_admin\_role\_arn) | ARN of the IAM role for GitHub Actions with admin permissions |
| <a name="output_github_actions_dns_role_arn"></a> [github\_actions\_dns\_role\_arn](#output\_github\_actions\_dns\_role\_arn) | ARN of the IAM role for GitHub Actions with DNS management permissions |
<!-- END_TF_DOCS -->
