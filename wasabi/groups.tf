# -----------------------------------------------------------------------------
# Wasabi – IAM Groups
# -----------------------------------------------------------------------------

resource "aws_iam_group" "admins" {
  provider = aws.wasabi
  name     = "admins"
}

resource "aws_iam_group_membership" "admins" {
  provider = aws.wasabi
  name     = "admins"
  group    = aws_iam_group.admins.name

  users = [
    # This is like the python expression:
    # [user_modules[name].name for name, config in wasabi_users.items() if config.get('is_admin', False)]
    for name, config in local.wasabi_users : module.user[name].name
    if try(config.is_admin, false)
  ]
}

resource "aws_iam_group_policy_attachment" "admins_administrator_access" {
  provider   = aws.wasabi
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
