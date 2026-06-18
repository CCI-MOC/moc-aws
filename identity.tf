# -----------------------------------------------------------------------------
# IAM Identity Center – Groups
# -----------------------------------------------------------------------------

resource "aws_identitystore_group" "moc_aws_admins" {
  identity_store_id = local.identity_store_id
  display_name      = "moc-aws-admins"
  description       = "Users with admin access to AWS."
}

# -----------------------------------------------------------------------------
# IAM Identity Center – Users
# -----------------------------------------------------------------------------

resource "aws_identitystore_user" "lars" {
  identity_store_id = local.identity_store_id
  user_name         = "lars"
  display_name      = "Lars Kellogg-Stedman"

  name {
    given_name  = "Lars"
    family_name = "Kellogg-Stedman"
  }

  emails {
    value   = "lars@redhat.com"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_user" "naved" {
  identity_store_id = local.identity_store_id
  user_name         = "naved"
  display_name      = "Naved Ansari"

  name {
    given_name  = "Naved"
    family_name = "Ansari"
  }

  emails {
    value   = "naved001@bu.edu"
    type    = "work"
    primary = true
  }
}

# -----------------------------------------------------------------------------
# IAM Identity Center – Group memberships
# -----------------------------------------------------------------------------

resource "aws_identitystore_group_membership" "lars_in_moc_aws_admins" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.moc_aws_admins.group_id
  member_id         = aws_identitystore_user.lars.user_id
}

resource "aws_identitystore_group_membership" "naved_in_moc_aws_admins" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.moc_aws_admins.group_id
  member_id         = aws_identitystore_user.naved.user_id
}
