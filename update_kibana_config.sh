#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

eval "${KUBECTL} create configmap kibana-config --from-file=kibana.yml --dry-run -o yaml" | eval "${KUBECTL} replace -f -" || eval "${KUBECTL} create configmap kibana-config --from-file=kibana.yml"
# Just remove pods and deployments will recreate new ones with updated config file
eval "${KUBECTL} delete pods -l k8s-app=kibana-logging,version=v2"
