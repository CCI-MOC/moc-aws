# Permission Set

Manage AWS Identity Center [permission sets].

[permission sets]: https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html

## Example usage

```hcl
module "view_only_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "ViewOnlyAccess"
  managed_policy_arns = {
    view_only_access = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.this["moc-aws-admins"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
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
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_ssoadmin_customer_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_managed_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | ARN of the SSO instance | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the permission set | `string` | n/a | yes |
| <a name="input_assignments"></a> [assignments](#input\_assignments) | Map of account assignments (key = stable name, value = assignment config) | <pre>map(object({<br/>    principal_id   = string<br/>    principal_type = string<br/>    target_id      = string<br/>  }))</pre> | `{}` | no |
| <a name="input_customer_managed_policy_names"></a> [customer\_managed\_policy\_names](#input\_customer\_managed\_policy\_names) | Map of customer managed policy names to attach (key = stable name, value = policy name) | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the permission set | `string` | `null` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | Map of AWS managed policy ARNs to attach (key = stable name, value = ARN) | `map(string)` | `{}` | no |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | Session duration in ISO 8601 format | `string` | `"PT2H"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the permission set |
<!-- END_TF_DOCS -->
