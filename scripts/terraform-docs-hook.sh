#!/bin/bash

terraform-docs .

set globstar

for dir in $(find ./**/modules wasabi -name '*.tf' -exec dirname {} \; | sort -u); do
  terraform-docs --config modules/.terraform-docs.yml "$dir"
done
