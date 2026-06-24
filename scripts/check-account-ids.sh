#!/bin/bash

set -eu

account_ids=""

# Collect account IDs from environment variables
for var in TF_VAR_aws_account_id TF_VAR_aws_account_id_secondary; do
  if [[ -n "${!var:-}" ]]; then
    account_ids="$account_ids ${!var}"
  fi
done

# Fall back to parsing local.tfvars if it exists
if [ -f local.tfvars ]; then
  for var in aws_account_id aws_account_id_secondary; do
    val=$(sed -n "s/^${var}[[:space:]]*=[[:space:]]*\"\([^\"]*\)\".*/\1/p" local.tfvars)
    if [ -n "$val" ]; then
      account_ids="$account_ids $val"
    fi
  done
fi

# Deduplicate
account_ids=$(echo "$account_ids" | tr ' ' '\n' | sort -u | grep . || true)

if [ -z "$account_ids" ]; then
  echo "WARNING: no AWS account IDs found in environment or local.tfvars; skipping check" >&2
  exit 0
fi

pattern=$(paste -sd'|' <<<"$account_ids")
status=0

for file in "$@"; do
  if grep -nE "$pattern" "$file"; then
    echo "^^^ Found AWS account ID in $file" >&2
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo "ERROR: staged files contain AWS account IDs" >&2
fi

exit "$status"
