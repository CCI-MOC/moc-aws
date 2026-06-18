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
