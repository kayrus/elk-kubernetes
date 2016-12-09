#!/bin/sh

set -e
#set -x

export ES_WAIT_FOR_RETRY=30
export ES_CLIENT_ENDPOINT=${ES_CLIENT_ENDPOINT:-"http://elasticsearch:9200"}

echo "Prepare stopping of ${HOSTNAME} pod"

echo "Prepare to migrate data of the node"

NODE_IP=$(curl -s -XGET "${ES_CLIENT_ENDPOINT}/_nodes/${HOSTNAME}" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .host")
if [ "${NODE_IP}" = "x" ]; then
  echo "Cannot find current node in cluster's stats, exiting..."
  exit 1
fi

DOC_COUNT=$(curl -s -XGET "${ES_CLIENT_ENDPOINT}/_nodes/${HOSTNAME}/stats/indices" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")

if [ "${DOC_COUNT}" -gt 0 ]; then
  echo "Node contains ${DOC_COUNT} documents"
  echo "Wait for node to become empty"
  curl -s -XPUT "${ES_CLIENT_ENDPOINT}/_cluster/settings?pretty" -d "{\"transient\":{\"cluster.routing.allocation.exclude._name\":\"${HOSTNAME}\"}}"
  echo "Move out data from node (${NODE_IP})"
else
  echo "Node (${NODE_IP}) doesn't conain data (${DOC_COUNT} documents)"
fi

while [ "${DOC_COUNT}" -gt 0 ]; do
  EXCLUDED_NODE=$(curl -s "${ES_CLIENT_ENDPOINT}/_cluster/settings" | jq -r '.transient.cluster.routing.allocation.exclude._name')
  if [ "${EXCLUDED_NODE}" != "${HOSTNAME}" ]; then
    echo "Current node (${HOSTNAME}) is not excluded from the cluster, found '${EXCLUDED_NODE}'"
    echo "Most probably you've requested more than one node shutdown, waiting ${ES_WAIT_FOR_RETRY} seconds to check the excluded list and retry..."
    sleep ${ES_WAIT_FOR_RETRY}
    continue
  fi
  DOC_COUNT=$(curl -s -XGET "${ES_CLIENT_ENDPOINT}/_nodes/${HOSTNAME}/stats/indices" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")
  RELOCATING_SHARDS=$(curl -s -XGET "${ES_CLIENT_ENDPOINT}/_cluster/health" | jq -r ".relocating_shards")
  echo "Node (${NODE_IP}) contains ${DOC_COUNT} documents, relocating ${RELOCATING_SHARDS} shards..."
  sleep 1
done

echo "Node clear to shutdown"
