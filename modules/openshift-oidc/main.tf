# -----------------------------------------------------------------------------
# OpenShift OIDC – IAM OIDC provider
# -----------------------------------------------------------------------------

locals {
  oidc_issuer_url  = "https://${var.oidc_bucket_domain_name}/${var.cluster_name}"
  oidc_issuer_host = "${var.oidc_bucket_domain_name}/${var.cluster_name}"
}

resource "aws_iam_openid_connect_provider" "this" {
  url             = local.oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = []

  lifecycle {
    ignore_changes = [thumbprint_list]
  }
}

# -----------------------------------------------------------------------------
# Store OIDC outputs in Secrets Manager
# -----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "oidc" {
  name                    = "cluster/${var.cluster_name}/aws-oidc"
  description             = "OIDC configuration for cluster ${var.cluster_name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "oidc" {
  secret_id = aws_secretsmanager_secret.oidc.id
  secret_string = jsonencode({
    cert_manager_role_arn = aws_iam_role.cert_manager.arn
    eso_role_arn          = aws_iam_role.eso.arn
    oidc_issuer_url       = local.oidc_issuer_url
  })
}
