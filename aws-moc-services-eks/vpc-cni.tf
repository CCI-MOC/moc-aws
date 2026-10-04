# --- VPC CNI add-on ---
#
# Brings the EKS-installed vpc-cni add-on under Terraform management so we can
# enable prefix delegation. Without this, ENI-based IP allocation caps pods
# per node well below what the instance type's ENI/prefix limits allow (e.g.
# 17 on t3.medium).

resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "vpc-cni"

  configuration_values = jsonencode({
    env = {
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
    }
  })

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_node_group.default]
}
