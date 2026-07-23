data "aws_route53_zone" "this" {
  name = var.zone_name
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "ListRecordsInZone"
    effect = "Allow"
    actions = [
      "route53:ListResourceRecordSets",
    ]
    resources = [data.aws_route53_zone.this.arn]
  }

  statement {
    sid    = "ManageACMETXTRecords"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [data.aws_route53_zone.this.arn]

    condition {
      test     = "StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }

    condition {
      test     = "StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values = [
        "_acme-challenge.api.${var.cluster_subdomain}",
        "_acme-challenge.apps.${var.cluster_subdomain}",
        "_acme-challenge.${var.cluster_subdomain}",
      ]
    }
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

resource "aws_iam_policy" "this" {
  name        = var.policy_name
  description = var.policy_description
  policy      = data.aws_iam_policy_document.this.json
}
