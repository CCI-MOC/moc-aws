#!/usr/bin/env bash
#
# Deletes all Ingresses and type: LoadBalancer Services from the cluster so the
# AWS Load Balancer Controller removes the backing AWS load balancers (and their
# ENIs) before the controller is uninstalled.
#
# `kubectl delete --wait` blocks on the controller's finalizers, so this returns
# only once the AWS load balancers are actually gone. If deletion does not
# complete within TIMEOUT, kubectl exits non-zero and so does this script, which
# fails `tofu destroy` while the controller is still installed -- letting the
# operator fix the problem and retry rather than orphaning ENIs that would then
# block VPC deletion.
set -euo pipefail

: "${CLUSTER_NAME:?CLUSTER_NAME must be set}"
: "${AWS_REGION:?AWS_REGION must be set}"
TIMEOUT="${TIMEOUT:-600s}"

# Use an isolated, temporary kubeconfig so we don't disturb the operator's.
KUBECONFIG_FILE="$(mktemp)"
export KUBECONFIG="$KUBECONFIG_FILE"
trap 'rm -f "$KUBECONFIG_FILE"' EXIT

aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null

echo "Deleting all Ingresses (waiting up to ${TIMEOUT} for finalizers)..."
kubectl delete ingress --all --all-namespaces --wait --timeout="$TIMEOUT"

echo "Finding type: LoadBalancer Services..."
# kubectl cannot field-select on spec.type, so filter with jsonpath.
lb_services="$(
  kubectl get services --all-namespaces \
    -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}'
)"

if [[ -z "${lb_services//[[:space:]]/}" ]]; then
  echo "No LoadBalancer Services found."
  exit 0
fi

echo "Deleting LoadBalancer Services (waiting up to ${TIMEOUT} for finalizers)..."
while read -r namespace name; do
  [[ -z "$namespace" || -z "$name" ]] && continue
  echo "  - ${namespace}/${name}"
  kubectl delete service "$name" --namespace "$namespace" --wait --timeout="$TIMEOUT"
done <<<"$lb_services"

echo "Load balancer cleanup complete."
