#!/bin/bash

terraform-docs .

find ./* -name 'main.tf' \! -path ./main.tf -printf '%h\n' |
  xargs -IDIR terraform-docs --config modules/.terraform-docs.yml "DIR"
