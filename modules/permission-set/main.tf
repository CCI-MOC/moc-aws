resource "aws_ssoadmin_permission_set" "this" {
  instance_arn     = var.instance_arn
  name             = var.name
  description      = var.description
  session_duration = var.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = var.managed_policy_arns

  instance_arn       = var.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
}

resource "aws_ssoadmin_customer_managed_policy_attachment" "this" {
  for_each = var.customer_managed_policy_names

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  customer_managed_policy_reference {
    name = each.value
  }
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = var.assignments

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.target_id
  target_type        = "AWS_ACCOUNT"
}
