#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

eval "${KUBECTL} create configmap kaae-config --from-file=kaae.json --dry-run -o yaml" | eval "${KUBECTL} replace -f -"
# Just remove pods and deployments will recreate new ones with updated config file
eval "${KUBECTL} delete pods -l k8s-app=kibana-logging,version=v2"
