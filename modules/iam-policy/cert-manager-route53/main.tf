data "aws_route53_zone" "this" {
  name = var.zone_name
}

data "aws_route53_zone" "additional" {
  for_each = toset(var.additional_zone_names)
  name     = each.value
}

locals {
  default_challenge_names = var.cluster_subdomain != null ? [
    "_acme-challenge.api.${var.cluster_subdomain}",
    "_acme-challenge.apps.${var.cluster_subdomain}",
    "_acme-challenge.${var.cluster_subdomain}",
  ] : []

  all_challenge_names = concat(
    local.default_challenge_names,
    [for name in var.additional_challenge_names : "_acme-challenge.${name}"],
    # Every additional zone implicitly permits ACME challenges for any name
    # within it, so declaring the zone is enough -- no separate
    # additional_challenge_names entry is required for its own records.
    [for z in var.additional_zone_names : "_acme-challenge.*.${z}"],
  )

  # Every hosted zone whose records this policy may touch: the primary zone
  # plus any delegated subdomain zones passed via additional_zone_names.
  zone_arns = concat(
    [data.aws_route53_zone.this.arn],
    [for z in data.aws_route53_zone.additional : z.arn],
  )
}

data "aws_iam_policy_document" "this" {
  statement {
    sid    = "ListRecordsInZone"
    effect = "Allow"
    actions = [
      "route53:ListResourceRecordSets",
    ]
    resources = local.zone_arns
  }

  statement {
    sid    = "ManageACMETXTRecords"
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = local.zone_arns

    condition {
      test     = "StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }

    condition {
      test     = "StringLike"
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
      values   = local.all_challenge_names
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
