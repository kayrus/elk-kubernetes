#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"

kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete configmaps fluentd-config
kubectl ${CONTEXT} --namespace="${NAMESPACE}" create configmap fluentd-config --from-file=docker/fluentd/td-agent.conf
kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete $(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -o name | awk '/pod\/fluentd-elasticsearch/')
