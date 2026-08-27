# -----------------------------------------------------------------------------
# IAM Identity Center – Users
# -----------------------------------------------------------------------------

locals {
  sso_users = {
    "lars" = {
      display_name = "Lars Kellogg-Stedman"
      given_name   = "Lars"
      family_name  = "Kellogg-Stedman"
      email        = "lars@redhat.com"
      groups       = ["moc-aws-admins"]
    }
    "naved" = {
      display_name = "Naved Ansari"
      given_name   = "Naved"
      family_name  = "Ansari"
      email        = "naved001@bu.edu"
      groups       = ["moc-aws-admins"]
    }
    "knikolla" = {
      display_name = "Kristi Nikolla"
      given_name   = "Kristi"
      family_name  = "Nikolla"
      email        = "knikolla@bu.edu"
      groups       = ["moc-aws-admins"]
    }
    "computate" = {
      display_name = "Christoper Tate"
      given_name   = "Christopher"
      family_name  = "Tate"
      email        = "ctate@redhat.com"
      groups       = ["moc-aws-eks-operators"]
    }
    "quanmp" = {
      display_name = "Quan Pham"
      given_name   = "Quan"
      family_name  = "Pham"
      email        = "quanmp@bu.com"
      groups       = ["moc-aws-secrets-manager-operators"]
    }
    "tzumainn" = {
      display_name = "Tzu-Mainn Chen"
      given_name   = "Tzu-Mainn"
      family_name  = "Chen"
      email        = "tzumainn@redhat.com"
      groups       = ["moc-aws-secrets-manager-operators"]
    }
    "sdanni" = {
      display_name = "Danni Shi"
      given_name   = "Danni"
      family_name  = "Shi"
      email        = "sdanni@redhat.com"
      groups       = ["moc-aws-secrets-manager-operators"]
    }
  }
}

resource "aws_identitystore_user" "this" {
  for_each          = local.sso_users
  identity_store_id = local.identity_store_id
  user_name         = each.key
  display_name      = each.value.display_name

  name {
    given_name  = each.value.given_name
    family_name = each.value.family_name
  }

  emails {
    value   = each.value.email
    type    = "work"
    primary = true
  }
}

# -----------------------------------------------------------------------------
# IAM Identity Center – Group memberships
# -----------------------------------------------------------------------------

locals {
  group_memberships = merge([
    for user_name, user in local.sso_users : {
      for group in user.groups :
      "${user_name}_in_${replace(group, "-", "_")}" => {
        user_name  = user_name
        group_name = group
      }
    }
  ]...)
}

resource "aws_identitystore_group_membership" "this" {
  for_each          = local.group_memberships
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.this[each.value.group_name].group_id
  member_id         = aws_identitystore_user.this[each.value.user_name].user_id
}
