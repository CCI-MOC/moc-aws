#!/bin/bash

exec aws resource-explorer-2 search --query-string='-tag:managed-by=moc-aws' |
  jq -r '.Resources[]|[.ResourceType,.Arn]|@tsv' |
  column -t
