# -----------------------------------------------------------------------------
# SSO – Permission sets
# -----------------------------------------------------------------------------

module "administrator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "AdministratorAccess"
  managed_policy_arns = {
    administrator_access = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.moc_aws_admins.group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
    moc_aws_admins_secondary = {
      principal_id   = aws_identitystore_group.moc_aws_admins.group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id_secondary
    }
  }
}

module "view_only_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "ViewOnlyAccess"
  managed_policy_arns = {
    view_only_access = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.moc_aws_admins.group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

# -----------------------------------------------------------------------------
# Managed policy – Route53 record management
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "route53_records" {
  statement {
    sid    = "AllowRoute53RecordManagement"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "route53_records" {
  name   = "Route53Records"
  policy = data.aws_iam_policy_document.route53_records.json
}

# -----------------------------------------------------------------------------
# SSO – Route53Records permission set
# -----------------------------------------------------------------------------

module "route53_records" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "Route53Records"
  description  = "List hosted zones and manage DNS records"
  customer_managed_policy_names = {
    route53_records = aws_iam_policy.route53_records.name
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.moc_aws_admins.group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}
