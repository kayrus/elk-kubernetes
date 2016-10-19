#!/bin/sh

set -e
#set -x

SERVICE_ACCOUNT_PATH=/var/run/secrets/kubernetes.io/serviceaccount
KUBE_TOKEN=$(cat ${SERVICE_ACCOUNT_PATH}/token)
KUBE_NAMESPACE=$(cat ${SERVICE_ACCOUNT_PATH}/namespace)

echo "Prepare stopping of ${HOSTNAME} pod"

echo "Prepare to migrate data of the node"

NODE_STATS=$(curl -s -XGET "http://elasticsearch-logging:9200/_nodes/${HOSTNAME}/stats")
NODE_IP=$(echo "${NODE_STATS}" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .host")
DOC_COUNT=$(echo "${NODE_STATS}" | jq ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")

echo "Move all data from node ${NODE_IP}"

curl -s -XPUT 'http://elasticsearch-logging:9200/_cluster/settings' -d "{
  \"transient\" :{
      \"cluster.routing.allocation.exclude._host\" : \"${NODE_IP}\"
   }
}"
echo

echo "Wait for node to become empty"
DOC_COUNT=$(echo "${NODE_STATS}" | jq ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")
while [ "${DOC_COUNT}" -gt 0 ]; do
  NODE_STATS=$(curl -s -XGET "http://elasticsearch-logging:9200/_nodes/${HOSTNAME}/stats")
  DOC_COUNT=$(echo "${NODE_STATS}" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")
  echo "Node contains ${DOC_COUNT} documents"
  sleep 1
done

echo "Node clear to shutdown"
kill -s TERM 1
