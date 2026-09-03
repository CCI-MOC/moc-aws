#!/bin/bash

terraform-docs .

find ./* -name 'main.tf' \! -path ./main.tf -exec dirname {} \; |
  xargs -IDIR terraform-docs --config modules/.terraform-docs.yml "DIR"
