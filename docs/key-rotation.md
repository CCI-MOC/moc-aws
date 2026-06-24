# Rotating IAM Access Keys

To rotate an IAM access key without changing its label, use `tofu apply -replace` to
force recreation of the key resource.

## Usage

```sh
tofu apply -replace='module.iam_user["<USER>"].aws_iam_access_key.this["<KEY_LABEL>"]'
```

For example, to rotate the `cert-manager-nist-clusters` key on the
`cert-manager-ocp-massopen` user:

```sh
tofu apply -replace='module.iam_user["cert-manager-ocp-massopen"].aws_iam_access_key.this["cert-manager-nist-clusters"]'
```

This destroys the old access key and creates a new one in a single apply. The new
credentials are automatically stored in the corresponding Secrets Manager secret
(`iam-user/<user>/<key_label>`).

## Notes

- The old access key is immediately invalidated when the apply runs. Update any
  services using the key immediately after rotation.
- The Secrets Manager secret version is also replaced, so anything reading from
  Secrets Manager will pick up the new credentials automatically.
