#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"

kubectl ${CONTEXT} --namespace="${NAMESPACE}" create configmap fluentd-config --from-file=docker/fluentd/td-agent.conf --dry-run -o yaml | kubectl ${CONTEXT} --namespace="${NAMESPACE}" apply -f -
# Just remove pods and daemonsets will recreate new ones with updated config file
kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete $(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -o name | awk '/pod\/fluentd-elasticsearch/')
