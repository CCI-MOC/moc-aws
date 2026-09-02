variable "dns_policy_arn" {
  description = "ARN of the managed IAM policy for Route53 record management"
  type        = string
}

variable "state_bucket" {
  description = "Name of the S3 bucket holding OpenTofu state"
  type        = string
  default     = "moc-tf-state"
}

variable "consumer_repos" {
  description = "Reduced-privilege GitHub Actions roles for other repositories. Map key is used to name the role (github-actions-<key>)."
  type = map(object({
    repository         = string
    state_keys         = list(string)
    ro_secret_prefixes = optional(list(string), [])
    rw_secret_prefixes = optional(list(string), [])
    # OIDC subject (token.actions.githubusercontent.com:sub) patterns the role
    # will trust. Leave unset for the default "repo:<repository>:*". Set it for
    # repos whose subject uses GitHub's immutable IDs
    # (repo:<org>@<org_id>/<repo>@<repo_id>:*), which the default cannot match.
    # Discover the exact prefix (append ":*") with:
    #   gh api repos/<org>/<repo>/actions/oidc/customization/sub --jq .sub_claim_prefix
    subject_claims = optional(list(string))
  }))
  default = {}

  validation {
    condition     = alltrue([for r in var.consumer_repos : length(r.state_keys) > 0])
    error_message = "Each consumer_repos entry must declare at least one state_keys value; an empty list would render an IAM policy with no resources, which AWS rejects at apply time."
  }
}
