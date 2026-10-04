# --- Cluster IAM role ---

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# --- EKS cluster ---

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  version  = var.kubernetes_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = concat(values(aws_subnet.public)[*].id, values(aws_subnet.private)[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_policy]

  lifecycle {
    # bootstrap_cluster_creator_admin_permissions is a create-only field the
    # EKS API never returns, so leaving it unmanaged here avoids a spurious
    # "force replacement" diff when adopting access_config on an existing
    # cluster.
    ignore_changes = [access_config[0].bootstrap_cluster_creator_admin_permissions]
  }
}

# --- OIDC provider (for IRSA) ---

data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}
# --- Node group IAM role ---

resource "aws_iam_role" "node_group" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_ssm" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# --- Cluster access (EKS access entries) ---

locals {
  # cluster_admins holds role paths (no account ID, per repo convention); build
  # the full principal ARNs from the current account.
  cluster_admin_arns = [
    for role in var.cluster_admins :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role}"
  ]
}

resource "aws_eks_access_entry" "admin" {
  for_each      = toset(local.cluster_admin_arns)
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  for_each      = toset(local.cluster_admin_arns)
  cluster_name  = aws_eks_cluster.cluster.name
  principal_arn = each.value
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.admin]
}

# --- Node group launch template ---
#
# Overrides kubelet's max-pods via a nodeadm NodeConfig (AL2023) so nodes
# actually use the higher pod density that prefix delegation (vpc-cni.tf)
# makes available. Without this, EKS's generated bootstrap config still caps
# pods using the non-prefix ENI table (17 on t3.medium). EKS merges this
# NodeConfig with the cluster-join config it generates itself.
resource "aws_launch_template" "node_group" {
  name_prefix = "${var.cluster_name}-node-"

  user_data = base64encode(<<-EOT
    MIME-Version: 1.0
    Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

    --==MYBOUNDARY==
    Content-Type: application/node.eks.aws

    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      kubelet:
        config:
          maxPods: 110

    --==MYBOUNDARY==--
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Managed node group ---

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "default"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = values(aws_subnet.private)[*].id
  instance_types  = [var.eks_instance_type]

  scaling_config {
    desired_size = var.node_desired_count
    min_size     = var.node_min_count
    max_size     = var.node_max_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_ssm,
    # Nodes launch into the private subnets and need outbound egress (ECR
    # image pulls, cluster registration) before they can join. Without these
    # the node group races ahead of the NAT route and never becomes Ready.
    aws_route.private_nat,
    aws_route_table_association.private,
  ]
}

# --- Managed node group (prefix delegation, max-pods override) ---
#
# A second node group running the launch template above, so adopting it
# doesn't force-replace the existing "default" node group (attaching a
# launch_template to a node group that doesn't have one is a destructive
# replace in both the EKS API and this provider). Once workloads have
# migrated over, scale "default" to zero and remove it from this config.
resource "aws_eks_node_group" "default_v2" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "default-v2"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = values(aws_subnet.private)[*].id
  instance_types  = [var.eks_instance_type_v2]
  ami_type        = "AL2023_x86_64_STANDARD"

  launch_template {
    id      = aws_launch_template.node_group.id
    version = aws_launch_template.node_group.latest_version
  }

  scaling_config {
    desired_size = var.node_desired_count
    min_size     = var.node_min_count
    max_size     = var.node_max_count
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
    aws_iam_role_policy_attachment.node_ssm,
    aws_route.private_nat,
    aws_route_table_association.private,
    # Nodes advertise maxPods: 110 via the launch template's NodeConfig
    # regardless of CNI mode. Without this, nodes can join before vpc-cni
    # has prefix delegation enabled and get stuck unable to allocate IPs
    # for pods beyond the non-prefix ENI limit.
    aws_eks_addon.vpc_cni,
  ]
}
