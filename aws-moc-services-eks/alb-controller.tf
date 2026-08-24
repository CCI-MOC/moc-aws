# --- IAM policy (fetched from upstream) ---

data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.9.2/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-AWSLoadBalancerControllerPolicy"
  policy = data.http.alb_controller_policy.response_body
}

# --- IRSA role ---

locals {
  oidc_issuer = replace(aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
}

data "aws_iam_policy_document" "alb_controller_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "${var.cluster_name}-alb-controller-role"
  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role.json
}

resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# --- Helm release ---

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = aws_vpc.main.id
  }

  depends_on = [
    aws_eks_node_group.default,
    aws_iam_role_policy_attachment.alb_controller,
  ]
}

# --- Destroy-time cleanup of controller-managed load balancers ---
#
# The ALB controller creates AWS load balancers (and ENIs in the VPC subnets) in
# response to Ingresses and type: LoadBalancer Services. Those AWS resources are
# not tracked in state, so on `tofu destroy` they would be orphaned once the
# controller is uninstalled -- and their lingering ENIs block VPC deletion.
#
# This resource depends on the Helm release, so at destroy time it is torn down
# *before* the controller is uninstalled. Its destroy-time provisioner deletes
# the Ingresses and type: LoadBalancer Services while the controller is still
# running, letting the controller remove the backing AWS load balancers first.
# The script blocks on finalizers and fails the destroy if cleanup does not
# complete, leaving the controller installed so the operation can be retried.
resource "terraform_data" "lb_cleanup" {
  triggers_replace = {
    cluster_name = aws_eks_cluster.cluster.name
    region       = var.region
  }

  depends_on = [helm_release.alb_controller]

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/cleanup-load-balancers.sh"

    environment = {
      CLUSTER_NAME = self.triggers_replace.cluster_name
      AWS_REGION   = self.triggers_replace.region
    }
  }
}
