# AWS resource management for the Mass Open Cloud

This repository uses OpenTofu to manage AWS resources for the Mass Open Cloud.

## What is OpenTofu?

[OpenTofu] is the open source fork of [Terraform].

OpenTofu is an infrastructure-as-code tool that lets you define resources (like
AWS EC2 instances, S3 buckets, IAM policies, etc) in declarative configuration
files written in [HCL] (HashiCorp Configuration Language). It maintains a state
file that tracks every resource it has created,  including metadata like
resource IDs, attributes, and dependencies.

On each run, OpenTofu compares the configuration against the saved state (and
optionally refreshes it against the real cloud environment) to compute the
minimal set of changes needed -- creating, updating, or destroying resources as
necessary. The state file is typically stored remotely (e.g., in an S3 bucket)
so that multiple team members can work against the same shared view of
infrastructure, and state locking prevents concurrent runs from conflicting
with each other.

[hcl]: https://github.com/hashicorp/hcl/blob/main/README.md
[opentofu]: https://opentofu.org/
[terraform]: https://developer.hashicorp.com/terraform

## Authenticating to AWS

*Preqrequisites*: you must have an SSO acount in the MOC IAM Identity Center.

1. Create an SSO session in your `~/.aws/config`:

    ```
    [sso-session moc-aws]
    sso_start_url = https://massopencloud.awsapps.com/start/
    sso_region = us-east-1
    sso_registration_scopes = sso:account:access
    ```

2. Create a profile in your `~/.aws/config`. A profile links an sso session to an account and a role name:

    ```
    [profile moc-admin]
    sso_session = moc-aws
    sso_account_id = 123456678912
    sso_role_name = AdministratorAccess
    region = us-east-1
    ```

    You will want to use our actual AWS account id for the value of `sso_account_id`.

3. Acquire credentials:

    ```sh
    aws sso login --profile moc-admin
    ```

    Complete the login exchange in your browser and you should be all set.

## Running OpenTofu

*Preqrequisites*: you must be authenticated to AWS with sufficient permissions to perform any actions required by the OpenTofu configuration.

### Initialize OpenTofu

If this is the first time you have used `tofu` in this repository, start by running:

```sh
tofu init
```

This should eventually result in the message:

```
OpenTofu has been successfully initialized!
```

### Show changes

To show any unapplied changes in the repository, run:

```sh
tofu plan
```

If there are no changes, you will see:

```
No changes. Your infrastructure matches the configuration.
```

If there are changes to be applied, you will see a summary of those changes. In this example, there is a change to a user's display name and a new hosted zone:

```
OpenTofu will perform the following actions:

  # aws_identitystore_user.lars will be updated in-place
  ~ resource "aws_identitystore_user" "lars" {
      ~ display_name      = "Lars Kellogg-Stedman" -> "Lars \"Chuckles\" Kellogg-Stedman"
        id                = "d-906672f641/e458a428-c0f1-7082-dea0-ce2d40334820"
        # (4 unchanged attributes hidden)

        # (2 unchanged blocks hidden)
    }

  # aws_route53_zone.lars_example_massopen_cloud will be created
  + resource "aws_route53_zone" "lars_example_massopen_cloud" {
      + arn                 = (known after apply)
      + comment             = "An example for the README"
      + force_destroy       = false
      + id                  = (known after apply)
      + name                = "lars-example.massopen.cloud"
      + name_servers        = (known after apply)
      + primary_name_server = (known after apply)
      + tags_all            = {
          + "managed-by" = "moc-aws"
        }
      + zone_id             = (known after apply)
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

### Apply changes


To apply changes to AWS, run:

```sh
tofu apply
```

This will show you the same output as `tofu plan`, and will then ask you whether or not you want to apply them:

```
Do you want to perform these actions?
  OpenTofu will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```
