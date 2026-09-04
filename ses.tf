# SES requires a verified email address to get started.
resource "aws_ses_email_identity" "contact" {
  email = "contact@massopen.cloud"
}

# A verified domain lets us send email from any address within the domain.
resource "aws_ses_domain_identity" "domain" {
  domain = "massopen.cloud"
}


data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail", "ses:SendEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "ses-sender-policy"
  description = "Allows sending emails via SES"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

# Point client's SMTP settings at the standard SES endpoint:
#
# - Host: email-smtp.<region>.amazonaws.com
# - Port: 587, with STARTTLS enabled
# - Username / Password: the username / password from the Secrets Manager secret
locals {
  smtp_credentials = {
    "keycloak-outbound-smtp" = {
      smtp_access_keys = {
        keycloak-outbound-smtp = {
          description = "Outbound email for Keycloak"
          secret_name = "cluster/moc-services/keycloak-outbound-smtp"
        }
      }
    }
  }
}

module "ses_smtp_user" {
  for_each = local.smtp_credentials
  source   = "./modules/iam-user"

  name             = each.key
  tags             = try(each.value.tags, {})
  smtp_access_keys = try(each.value.smtp_access_keys, {})
  policy_arns = {
    ses_sender = aws_iam_policy.ses_sender.arn
  }
}
