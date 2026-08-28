# --- EKS Pod Identity Agent add-on ---
#
# Runs as a DaemonSet on each node and brokers credentials for pod identity
# associations (see aws_eks_pod_identity_association in secretsmanager.tf). It
# uses the node role for its own permissions, so unlike the EBS CSI add-on it
# needs no service_account_role_arn.

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = "eks-pod-identity-agent"

  # The agent is a DaemonSet, so it needs schedulable nodes to come up.
  depends_on = [aws_eks_node_group.default]
}
