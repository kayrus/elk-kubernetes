#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"

kubectl ${CONTEXT} --namespace="${NAMESPACE}" apply -f es-fluentd-ds.yaml
