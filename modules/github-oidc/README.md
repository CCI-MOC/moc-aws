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

## Reduced-privilege roles for other repositories

Other repositories can be granted a scoped role via `consumer_repos`. Each entry
creates a role assumable only by that repository, with SecretsManager access
limited to the given name prefixes and write access limited to specific
`moc-tf-state` keys (default and `tofu` workspace layouts, including the
`.tflock` lock objects).

```hcl
module "github-oidc" {
  source         = "./modules/github-oidc"
  dns_policy_arn = aws_iam_policy.route53_records.arn

  consumer_repos = {
    widgets = {
      repository         = "CCI-MOC/moc-widgets"
      state_keys         = ["moc-widgets"]
      ro_secret_prefixes = ["shared/"]
      rw_secret_prefixes = ["moc-widgets/"]
    }
  }
}
```

The consuming repository configures its backend against a granted key and
assumes the role for its key from the `github_actions_consumer_role_arns`
map output. Because the output is a map, extract the entry with `jq`
(substitute your `consumer_repos` key for `widgets`):

```sh
gh secret set AWS_ROLE_ARN -b "$(tofu output -json github_actions_consumer_role_arns | jq -r '.widgets')"
```

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

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.github_actions_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions_consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.github_actions_dns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.github_actions_admin_deny_dangerous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.github_actions_consumer_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.github_actions_consumer_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.github_actions_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.github_actions_dns_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.github_actions_admin_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_admin_deny_dangerous](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_consumer_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_consumer_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_consumer_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_dns_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dns_policy_arn"></a> [dns\_policy\_arn](#input\_dns\_policy\_arn) | ARN of the managed IAM policy for Route53 record management | `string` | n/a | yes |
| <a name="input_consumer_repos"></a> [consumer\_repos](#input\_consumer\_repos) | Reduced-privilege GitHub Actions roles for other repositories. Map key is used to name the role (github-actions-<key>). | <pre>map(object({<br/>    repository         = string<br/>    state_keys         = list(string)<br/>    ro_secret_prefixes = optional(list(string), [])<br/>    rw_secret_prefixes = optional(list(string), [])<br/>    # OIDC subject (token.actions.githubusercontent.com:sub) patterns the role<br/>    # will trust. Leave unset for the default "repo:<repository>:*". Set it for<br/>    # repos whose subject uses GitHub's immutable IDs<br/>    # (repo:<org>@<org_id>/<repo>@<repo_id>:*), which the default cannot match.<br/>    # Discover the exact prefix (append ":*") with:<br/>    #   gh api repos/<org>/<repo>/actions/oidc/customization/sub --jq .sub_claim_prefix<br/>    subject_claims = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | Name of the S3 bucket holding OpenTofu state | `string` | `"moc-tf-state"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_github_actions_admin_role_arn"></a> [github\_actions\_admin\_role\_arn](#output\_github\_actions\_admin\_role\_arn) | ARN of the IAM role for GitHub Actions with admin permissions |
| <a name="output_github_actions_consumer_role_arns"></a> [github\_actions\_consumer\_role\_arns](#output\_github\_actions\_consumer\_role\_arns) | Map of consumer repo key to its GitHub Actions role ARN |
| <a name="output_github_actions_dns_role_arn"></a> [github\_actions\_dns\_role\_arn](#output\_github\_actions\_dns\_role\_arn) | ARN of the IAM role for GitHub Actions with DNS management permissions |
<!-- END_TF_DOCS -->
