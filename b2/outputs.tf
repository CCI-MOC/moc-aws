output "application_keys" {
  description = "Secrets Manager secrets containing B2 application keys"
  value = {
    for name, key in module.key : name => {
      secret_arn  = key.secret_arn
      secret_name = key.secret_name
    }
  }
}
