#!/bin/bash

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

render_template() {
  eval "echo \"$(< "$1")\""
}

CONTEXT=""
#CONTEXT="--context=foo"
NAMESPACE="monitoring"

ES_DATA_REPLICAS=$(kubectl get nodes --no-headers ${CONTEXT} | awk '!/SchedulingDisabled/ {print $1}' | wc -l)

for yaml in *.yaml.tmpl; do
  render_template "${yaml}" | kubectl ${CONTEXT} --namespace="${NAMESPACE}" create -f -
done

for yaml in *.yaml; do
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" create -f "${yaml}"
done

kubectl ${CONTEXT} --namespace="${NAMESPACE}" create configmap fluentd-config --from-file=docker/fluentd/td-agent.conf --dry-run -o yaml | kubectl ${CONTEXT} --namespace="${NAMESPACE}" apply -f -

# Set replicas to amount of worker nodes
#kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-data --replicas=${ES_DATA_REPLICAS}
#kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-master --replicas=${ES_DATA_REPLICAS}
#kubectl ${CONTEXT} --namespace="${NAMESPACE}" scale deployment es-data-master --replicas=${ES_DATA_REPLICAS}

# Wait for Elasticsearch client nodes
echo -n "Waiting for Elasticsearch client pods"
while true; do
  echo -n .
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -l role=client,component=elasticsearch -o jsonpath={.items[0].status.phase} | grep -q Running && break || sleep 1
done
echo

# Wait for Elasticsearch cluster readiness, and then apply "readinessProbe" to allow smooth rolling upgrade
echo -n "Waiting for Elasticsearch cluster readiness"
while true; do
  echo -n .
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" exec $(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -l role=client,component=elasticsearch -o jsonpath={.items[0].metadata.name}) -- sh -c 'curl -so/dev/null http://elasticsearch-logging:9200/_cluster/health?wait_for_status=green' >/dev/null 2>&1 && break || sleep 1
done
echo

# Apply readinessProbe only when our Elasticsearch cluster is up and running
kubectl ${CONTEXT} --namespace="${NAMESPACE}" patch deployment es-data-master -p'{"spec":{"template":{"spec":{"containers":[{"name":"es-data-master","readinessProbe":{"exec":{"command":["curl","-so/dev/null","http://elasticsearch-logging:9200/_cluster/health?wait_for_status=green"]},"timeoutSeconds":30,"successThreshold":3}}]}}}}'

kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods --watch
