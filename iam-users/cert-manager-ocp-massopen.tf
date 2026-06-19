# -- cert-manager-ocp-massopen ------------------------------------------------

data "aws_route53_zone" "ocp_massopen_cloud" {
  name = "ocp.massopen.cloud"
}

data "aws_iam_policy_document" "cert_manager_ocp_massopen" {
  statement {
    sid    = "ManageRecords"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [data.aws_route53_zone.ocp_massopen_cloud.arn]
  }

  statement {
    sid       = "GetChange"
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "ListZones"
    effect = "Allow"
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cert_manager_ocp_massopen" {
  name        = "ocp-massopen-cloud"
  description = "modify records in ocp.massopen.cloud mainly for the purposes for dns01 challenged."
  policy      = data.aws_iam_policy_document.cert_manager_ocp_massopen.json
}

module "cert_manager_ocp_massopen" {
  source = "../modules/iam-user"
  name   = "cert-manager-ocp-massopen"
  policy_arns = {
    ocp-massopen-cloud = aws_iam_policy.cert_manager_ocp_massopen.arn
  }
  tags = {
    "AKIAYLUGMT7YKZRT4APO" = "cert-manager-nist-clusters"
  }
}
