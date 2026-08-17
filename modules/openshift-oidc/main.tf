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
}
