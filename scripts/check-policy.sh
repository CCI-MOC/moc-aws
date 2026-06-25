#!/bin/bash

tfplan=

while getopts o: ch; do
  case $ch in
  o) tfplan=$OPTARG ;;
  \?) exit 2 ;;
  esac
done
shift $((OPTIND - 1))

if [[ -z $tfplan ]]; then
  tfplan=$(mktemp tfplanXXXXXX)
  tfplanjson="${tfplan}.json"
  files_to_clean+=("$tfplan" "$tfplanjson")
else
  tfplanjson=$(mktemp tfplanXXXXXX.json)
  files_to_clean=("$tfplanjson")
fi
trap 'rm -f "${files_to_clean[@]}"' EXIT

tofu plan -concise -input=false -out "$tfplan" &&
  tofu show -json "$tfplan" >"${tfplanjson}" &&
  docker run --rm -v "$PWD:/project" openpolicyagent/conftest test "${tfplanjson}"
