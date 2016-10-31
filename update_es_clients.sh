#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

#KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

./update_es_config.sh
eval "${KUBECTL} replace -f es-env.yaml"
eval "${KUBECTL} replace -f es-client.yaml"

eval "${KUBECTL} get pods $@"
