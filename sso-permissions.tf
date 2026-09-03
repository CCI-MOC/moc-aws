# -----------------------------------------------------------------------------
# SSO – Permission sets
# -----------------------------------------------------------------------------

module "administrator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "AdministratorAccess"
  managed_policy_arns = {
    administrator_access = "arn:aws:iam::aws:policy/AdministratorAccess"
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.this["moc-aws-admins"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
    moc_aws_admins_secondary = {
      principal_id   = aws_identitystore_group.this["moc-aws-admins"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id_secondary
    }
  }
}

module "operator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "OperatorAccess"
  managed_policy_arns = {
    operator_access        = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
    secrets_manager_access = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }
  assignments = {
    moc_aws_operators = {
      principal_id   = aws_identitystore_group.this["moc-aws-operators"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

module "eks_operator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "EKSOperatorAccess"
  description  = "SystemAdministrator plus EKS cluster management and scoped IAM for service roles"
  managed_policy_arns = {
    operator_access        = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
    secrets_manager_access = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }
  customer_managed_policy_names = {
    eks_access = aws_iam_policy.eks_access.name
  }
  assignments = {
    moc_aws_eks_operators = {
      principal_id   = aws_identitystore_group.this["moc-aws-eks-operators"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

module "secrets_manager_operator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "SecretsManagerOperatorAccess"
  description  = "Read and write access for AWS Secrets Manager"
  managed_policy_arns = {
    operator_access = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  }
  assignments = {
    moc_aws_secrets_manager_operators = {
      principal_id   = aws_identitystore_group.this["moc-aws-secrets-manager-operators"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

module "view_only_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "ViewOnlyAccess"
  managed_policy_arns = {
    view_only_access = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.this["moc-aws-admins"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

# -----------------------------------------------------------------------------
# Managed policy – EKS cluster management
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "eks_access" {
  statement {
    sid    = "AllowEKSFullAccess"
    effect = "Allow"

    actions = [
      "eks:*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowEKSIAMRoleManagement"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:CreateServiceLinkedRole",
      "iam:CreateOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:ListOpenIDConnectProviders",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRoleToEKS"
    effect = "Allow"

    actions = [
      "iam:PassRole",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "eks_access" {
  name   = "EKSAccess"
  policy = data.aws_iam_policy_document.eks_access.json
}

# -----------------------------------------------------------------------------
# Managed policy – MOC2 monitoring operators
# Statement SIDs are pack boundaries so this can be split into separate
# permission sets later without rewriting the action lists.
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "monitoring_operators" {
  statement {
    sid    = "AuditLoggingRead"
    effect = "Allow"

    actions = [
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetEventSelectors",
      "cloudtrail:GetTrail",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListTrails",
      "cloudtrail:LookupEvents",
      "config:Describe*",
      "config:Get*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AuditLoggingWrite"
    effect = "Allow"

    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:PutMetricAlarm",
      "events:DeleteRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
      "sns:Publish",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AuditLoggingDeny"
    effect = "Deny"

    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
      "s3:DeleteObject",
      "s3:PutBucketPolicy",
      "s3:PutObject",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ConfigComplianceRead"
    effect = "Allow"

    actions = [
      "config:Describe*",
      "config:Get*",
      "config:List*",
      "config:SelectResourceConfig",
      "securityhub:GetFindings",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ConfigComplianceWrite"
    effect = "Allow"

    actions = [
      "config:DeleteConfigRule",
      "config:DeleteConformancePack",
      "config:PutConfigRule",
      "config:PutConformancePack",
      "config:PutRemediationConfigurations",
      "config:StartConfigRulesEvaluation",
      "config:StartRemediationExecution",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ConfigComplianceDeny"
    effect = "Deny"

    actions = [
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:StopConfigurationRecorder",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CertificateRead"
    effect = "Allow"

    actions = [
      "acm:DescribeCertificate",
      "acm:ListCertificates",
      "acm:ListTagsForCertificate",
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudwatch:GetMetricData",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "CertificateWrite"
    effect = "Allow"

    actions = [
      "acm:AddTagsToCertificate",
      "acm:RenewCertificate",
      "acm:RequestCertificate",
      "cloudwatch:PutMetricAlarm",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SecretsRead"
    effect = "Allow"

    actions = [
      "cloudtrail:GetEventSelectors",
      "cloudtrail:LookupEvents",
      "cloudwatch:DescribeAlarms",
      "events:DescribeRule",
      "events:ListRules",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SecretsWrite"
    effect = "Allow"

    actions = [
      "secretsmanager:CancelRotateSecret",
      "secretsmanager:RotateSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UpdateSecretVersionStage",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SecretsDeny"
    effect = "Deny"

    actions = [
      "secretsmanager:BatchGetSecretValue",
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KmsRead"
    effect = "Allow"

    actions = [
      "cloudtrail:LookupEvents",
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:GetKeyRotationStatus",
      "kms:ListAliases",
      "kms:ListGrants",
      "kms:ListKeys",
      "kms:ListResourceTags",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KmsWrite"
    effect = "Allow"

    actions = [
      "kms:EnableKeyRotation",
      "kms:PutKeyPolicy",
      "kms:RevokeGrant",
      "kms:TagResource",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "KmsDeny"
    effect = "Deny"

    actions = [
      "kms:DeleteImportedKeyMaterial",
      "kms:DisableKey",
      "kms:DisableKeyRotation",
      "kms:ScheduleKeyDeletion",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "MonitoringCommonRead"
    effect = "Allow"

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "events:ListTargetsByRule",
      "sns:GetTopicAttributes",
      "sns:ListTopics",
      "tag:GetResources",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PrivilegeEscalationDeny"
    effect = "Deny"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateAccessKey",
      "iam:CreatePolicyVersion",
      "iam:CreateUser",
      "iam:DeleteRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:SetDefaultPolicyVersion",
      "iam:UpdateAssumeRolePolicy",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "monitoring_operators" {
  name   = "MonitoringOperators"
  policy = data.aws_iam_policy_document.monitoring_operators.json
}

module "monitoring_operator_access" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "MonitoringOperatorAccess"
  description  = "MOC2 monitoring operators: read/write access for CloudTrail, Config, ACM, Secrets metadata, KMS"
  customer_managed_policy_names = {
    monitoring_operators = aws_iam_policy.monitoring_operators.name
  }
  assignments = {
    moc_aws_monitoring_operators = {
      principal_id   = aws_identitystore_group.this["moc-aws-monitoring-operators"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}

# -----------------------------------------------------------------------------
# Managed policy – Route53 record management
# -----------------------------------------------------------------------------

data "aws_iam_policy_document" "route53_records" {
  statement {
    sid    = "AllowRoute53RecordManagement"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:GetChange",
      "route53:GetHostedZone",
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
      "route53:ListResourceRecordSets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "route53_records" {
  name   = "Route53Records"
  policy = data.aws_iam_policy_document.route53_records.json
}

# -----------------------------------------------------------------------------
# SSO – Route53Records permission set
# -----------------------------------------------------------------------------

module "route53_records" {
  source       = "./modules/permission-set"
  instance_arn = local.sso_instance_arn
  name         = "Route53Records"
  description  = "List hosted zones and manage DNS records"
  customer_managed_policy_names = {
    route53_records = aws_iam_policy.route53_records.name
  }
  assignments = {
    moc_aws_admins = {
      principal_id   = aws_identitystore_group.this["moc-aws-admins"].group_id
      principal_type = "GROUP"
      target_id      = var.aws_account_id
    }
  }
}
