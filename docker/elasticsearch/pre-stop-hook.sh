#!/bin/sh

set -e
#set -x

CLIENT_ENDPOINT="elasticsearch-logging:9200"

echo "Prepare stopping of ${HOSTNAME} pod"

echo "Prepare to migrate data of the node"

NODE_STATS=$(curl -s -XGET "http://${CLIENT_ENDPOINT}/_nodes/${HOSTNAME}/stats")
NODE_IP=$(echo "${NODE_STATS}" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .host")

echo "Move all data from node ${NODE_IP}"

curl -s -XPUT 'http://${CLIENT_ENDPOINT}/_cluster/settings' -d "{
  \"transient\" :{
      \"cluster.routing.allocation.exclude._host\" : \"${NODE_IP}\"
   }
}"
echo

echo "Wait for node to become empty"
DOC_COUNT=$(echo "${NODE_STATS}" | jq ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")
while [ "${DOC_COUNT}" -gt 0 ]; do
  NODE_STATS=$(curl -s -XGET "http://${CLIENT_ENDPOINT}/_nodes/${HOSTNAME}/stats")
  DOC_COUNT=$(echo "${NODE_STATS}" | jq -r ".nodes[] | select(.name==\"${HOSTNAME}\") | .indices.docs.count")
  echo "Node contains ${DOC_COUNT} documents"
  sleep 1
done

echo "Node clear to shutdown"
