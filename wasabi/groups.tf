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
    module.user["tschwesi"].name,
    module.user["lars"].name,
    module.user["naved001"].name,
  ]
}

resource "aws_iam_group_policy_attachment" "admins_administrator_access" {
  provider   = aws.wasabi
  group      = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
