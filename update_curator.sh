#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

./update_es_env.sh
eval "${KUBECTL} replace -f es-curator.yaml"
# Just remove pods and deployment will recreate new ones with an updated config
eval "${KUBECTL} delete pods -l k8s-app=es-curator"
