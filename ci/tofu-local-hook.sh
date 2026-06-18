#!/bin/sh

export TF_IN_AUTOMATION=true

if ! tofu fmt -check -diff; then
  tofu fmt
fi
