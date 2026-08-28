# --- Secrets Manager access via EKS Pod Identity ---
#
# Grants a specific Kubernetes service account read access to Secrets Manager
# secrets under a configured name prefix. The binding uses EKS Pod Identity
# rather than IRSA: the role is assumed by the pods.eks.amazonaws.com service
# principal and scoped to a single (namespace, service account) by the pod
# identity association below.

# Trust policy: assumed by the EKS Pod Identity service principal.
data "aws_iam_policy_document" "secrets_reader_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "secrets_reader" {
  name               = "${var.cluster_name}-secrets-reader-role"
  assume_role_policy = data.aws_iam_policy_document.secrets_reader_assume_role.json
}

# Permission policy: read secrets under the configured prefix only.
data "aws_iam_policy_document" "secrets_reader" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      "arn:aws:secretsmanager:*:*:secret:cluster/${var.cluster_name}/*",
      "arn:aws:secretsmanager:*:*:secret:cluster/common/*",
    ]
  }
}

resource "aws_iam_policy" "secrets_reader" {
  name   = "${var.cluster_name}-secrets-reader"
  policy = data.aws_iam_policy_document.secrets_reader.json
}

resource "aws_iam_role_policy_attachment" "secrets_reader" {
  role       = aws_iam_role.secrets_reader.name
  policy_arn = aws_iam_policy.secrets_reader.arn
}

# Bind (cluster, namespace, service account) -> role.
resource "aws_eks_pod_identity_association" "secrets_reader" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = var.secrets_reader_namespace
  service_account = var.secrets_reader_service_account
  role_arn        = aws_iam_role.secrets_reader.arn

  depends_on = [aws_eks_addon.pod_identity_agent]
}
