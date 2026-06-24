#!/bin/sh

terraform-docs .

for dir in $(find modules -name '*.tf' -exec dirname {} \; | sort -u); do
  terraform-docs --config modules/.terraform-docs.yml "$dir"
done
