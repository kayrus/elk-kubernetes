#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

CONTEXT=""
#CONTEXT="--context=foo"
NAMESPACE="monitoring"

INSTANCES="deployment/es-client deployment/es-data deployment/es-master deployment/es-data-master deployment/kibana-logging-v2 deployment/kubernetes-events-printer daemonset/fluentd-elasticsearch service/elasticsearch-logging service/elasticsearch-discovery service/kibana-logging configmap/es-env configmap/fluentd-config"

for instance in ${INSTANCES}; do
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete --grace-period=0 "${instance}"
done

PODS=$(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -o name | awk '/^pods\/es-/ {print $1}' | tr '\n' ' ')
while [ ! "${PODS}" = "" ]; do
  echo "Waiting 1 second for ${PODS}pods to shutdown..."
  sleep 1
  PODS=$(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -o name | awk '/^pods\/es-/ {print $1}' | tr '\n' ' ')
done
