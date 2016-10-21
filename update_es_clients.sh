#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

#KUBECTL_PARAMS="--context=foo"
NAMESPACE="monitoring"
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

eval "${KUBECTL} apply -f es-env.yaml"
eval "${KUBECTL} apply -f es-client.yaml"

eval "${KUBECTL} get pods $@"
