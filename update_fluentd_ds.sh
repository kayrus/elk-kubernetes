#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

eval "${KUBECTL} apply -f es-fluentd-ds.yaml"
