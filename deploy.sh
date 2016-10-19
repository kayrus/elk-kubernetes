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

kubectl ${CONTEXT} --namespace="${NAMESPACE}" get pods --watch
