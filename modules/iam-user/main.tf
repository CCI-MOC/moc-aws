resource "aws_iam_user" "this" {
  name = var.name
  tags = var.tags
  path = var.path
}

resource "aws_iam_access_key" "this" {
  for_each = var.access_keys
  user     = aws_iam_user.this.name
}

resource "aws_secretsmanager_secret" "access_key" {
  for_each    = var.access_keys
  name        = "iam-user/${var.name}/${each.key}"
  description = each.value
}

resource "aws_secretsmanager_secret_version" "access_key" {
  for_each  = var.access_keys
  secret_id = aws_secretsmanager_secret.access_key[each.key].id
  secret_string = jsonencode({
    label             = each.key
    access_key_id     = aws_iam_access_key.this[each.key].id
    secret_access_key = aws_iam_access_key.this[each.key].secret
  })
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each   = var.policy_arns
  user       = aws_iam_user.this.name
  policy_arn = each.value
}
