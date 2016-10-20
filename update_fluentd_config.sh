#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

eval "${KUBECTL} create configmap fluentd-config --from-file=docker/fluentd/td-agent.conf --dry-run -o yaml" | eval "${KUBECTL} apply -f -"
# Just remove pods and daemonsets will recreate new ones with updated config file
eval "${KUBECTL} delete $(eval "${KUBECTL} get pods -o name" | awk '/pod\/fluentd-elasticsearch/')"
