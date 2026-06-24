# -----------------------------------------------------------------------------
# GitHub OIDC – Provider and IAM role
# -----------------------------------------------------------------------------

# Define a policy that lets Github actions acquire AWS credentials using OIDC.

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
