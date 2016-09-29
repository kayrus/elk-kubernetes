#!/bin/bash

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

ES_DATA_REPLICAS=$(kubectl get nodes --no-headers ${CONTEXT} | awk '!/SchedulingDisabled/ {print $1}' | wc -l)

for yaml in `ls -L *.yaml`; do
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" create -f "${yaml}"
done

kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete configmap fluentd-config 2>/dev/null
kubectl ${CONTEXT} --namespace="${NAMESPACE}" create configmap fluentd-config --from-file=docker/fluentd/td-agent.conf

# Set replicas to amount of worker nodes
#kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-data --replicas=${ES_DATA_REPLICAS}
#kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-master --replicas=${ES_DATA_REPLICAS}
kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-data-master --replicas=${ES_DATA_REPLICAS}

kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods --watch
