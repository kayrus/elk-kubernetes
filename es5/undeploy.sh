#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

#KUBECTL_PARAMS="--context=foo"
NAMESPACE=${NAMESPACE:-monitoring}
KUBECTL="kubectl ${KUBECTL_PARAMS} --namespace=\"${NAMESPACE}\""

INSTANCES="deployment/es-client
deployment/es-data
deployment/es-master
deployment/es-data-master
deployment/kibana-v5
deployment/cerebro-v0
deployment/kubernetes-events-printer
deployment/es-curator
daemonset/fluentd-elasticsearch
service/elasticsearch-logging
service/elasticsearch-discovery
service/kibana
service/cerebro
configmap/es-env
configmap/fluentd-config"

for instance in ${INSTANCES}; do
  eval "${KUBECTL} delete --ignore-not-found --now \"${instance}\""
done

PODS=$(eval "${KUBECTL} get pods -o name" | awk '/^pod\/es-/ {print $1}' | tr '\n' ' ')
while [ ! "${PODS}" = "" ]; do
  echo "Waiting 1 second for ${PODS}pods to shutdown..."
  sleep 1
  eval "${KUBECTL} delete --now ${PODS}"
  PODS=$(eval "${KUBECTL} get pods -o name" | awk '/^pod\/es-/ {print $1}' | tr '\n' ' ')
done
