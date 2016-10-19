#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

print_red() {
  printf '%b' "\033[91m$1\033[0m\n"
}

print_green() {
  printf '%b' "\033[92m$1\033[0m\n"
}

render_template() {
  eval "echo \"$(cat "$1")\""
}

CONTEXT=""
#CONTEXT="--context=foo"
NAMESPACE="monitoring"

ES_DATA_REPLICAS=$(kubectl get nodes --no-headers ${CONTEXT} | awk '!/SchedulingDisabled/ {print $1}' | wc -l)

if [ "$ES_DATA_REPLICAS" -lt 3 ]; then
  print_red "Minimum amount of Elasticsearch data nodes is 3, exiting..."
  exit
fi

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
printf "Waiting for Elasticsearch client pods"
while true; do
  printf .
  kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -l role=client,component=elasticsearch --no-headers | grep -q Running && break || sleep 1
done
echo

# Wait for Elasticsearch cluster readiness, and then apply "readinessProbe" to allow smooth rolling upgrade
printf "Waiting for Elasticsearch cluster readiness"
# Emulating Kubernetes probe's "successThreshold: 3" and "periodSeconds: 3"
for i in 1 2 3; do
  while true; do
    printf .
    kubectl ${CONTEXT} --namespace="${NAMESPACE}" exec $(kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods -l role=client,component=elasticsearch -o jsonpath="{.items[0].metadata.name}") -- sh -c 'curl --max-time 1 -so/dev/null http://elasticsearch-logging:9200/_cluster/health?wait_for_status=green&timeout=2s' >/dev/null 2>&1 && break || sleep 1
  done
  sleep 3
done
echo

print_green "Applying \"readinessProbe\" onto es-data-master deployment..."
# Apply readinessProbe only when our Elasticsearch cluster is up and running
kubectl ${CONTEXT} --namespace="${NAMESPACE}" patch deployment es-data-master -p'{"spec":{"template":{"spec":{"containers":[{"name":"es-data-master","readinessProbe":{"exec":{"command":["curl","--max-time","28","-so/dev/null","http://elasticsearch-logging:9200/_cluster/health?wait_for_status=green&timeout=29s"]},"timeoutSeconds":30,"successThreshold":3,"periodSeconds":10}}]}}}}'

kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods --watch
