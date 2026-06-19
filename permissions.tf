# -----------------------------------------------------------------------------
# SSO – Permission sets
# -----------------------------------------------------------------------------

resource "aws_ssoadmin_permission_set" "administrator_access" {
  instance_arn     = local.sso_instance_arn
  name             = "AdministratorAccess"
  session_duration = "PT2H"
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator_access" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
}

resource "aws_ssoadmin_account_assignment" "moc_aws_admins_administrator_access" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
  principal_id       = aws_identitystore_group.moc_aws_admins.group_id
  principal_type     = "GROUP"
  target_id          = var.aws_account_id
  target_type        = "AWS_ACCOUNT"
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

resource "aws_ssoadmin_permission_set" "route53_records" {
  instance_arn     = local.sso_instance_arn
  name             = "Route53Records"
  description      = "List hosted zones and manage DNS records"
  session_duration = "PT2H"
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "route53_records" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.route53_records.arn
  customer_managed_policy_reference {
    name = aws_iam_policy.route53_records.name
  }
}

resource "aws_ssoadmin_account_assignment" "moc_aws_admins_route53_records" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.route53_records.arn
  principal_id       = aws_identitystore_group.moc_aws_admins.group_id
  principal_type     = "GROUP"
  target_id          = var.aws_account_id
  target_type        = "AWS_ACCOUNT"
}
