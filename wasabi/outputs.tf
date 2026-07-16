output "console_secrets" {
  description = "Secrets Manager secrets containing initial console passwords for Wasabi users"
  value = {
    for name, user in module.user : name => user.console_secret
    if user.console_secret != null
  }
}
