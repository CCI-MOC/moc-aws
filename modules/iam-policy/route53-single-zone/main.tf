data "aws_route53_zone" "this" {
  count = var.zone_name == null ? 0 : 1
  name  = var.zone_name
}

locals {
  zone_arn = coalesce(var.zone_arn, one(data.aws_route53_zone.this[*].arn))
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "ManageRecords"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = [local.zone_arn]
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
