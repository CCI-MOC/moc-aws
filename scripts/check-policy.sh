#!/bin/bash

tfplan=tfplan

while getopts o: ch; do
  case $ch in
  o) tfplan=$OPTARG ;;
  \?) exit 2 ;;
  esac
done
shift $((OPTIND - 1))

tmpfile=$(mktemp tfplanXXXXXX.json)
trap 'rm -f $tmpfile' EXIT

tofu plan -concise -input=false -out "$tfplan" &&
  tofu show -json "$tfplan" >"${tmpfile}" &&
  docker run --rm -v "$PWD:/project" openpolicyagent/conftest test "${tmpfile}"
