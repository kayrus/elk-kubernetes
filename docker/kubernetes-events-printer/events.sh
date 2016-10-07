#!/bin/sh -e

# oneliner
#curl -s "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT_HTTPS}/api/v1/watch/events?resourceVersion=$(curl -s "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT_HTTPS}/api/v1/events" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" | jq -r '.metadata.resourceVersion')" --cacert /var/run/secrets/kubernetes.io/serviceaccount/ca.crt -H "Authorization: Bearer $(cat /var/run/secrets/kubernetes.io/serviceaccount/token)"

KUBERNETES_SERVICE_HOST=${KUBERNETES_SERVICE_HOST:?Please specify KUBERNETES_SERVICE_HOST env variable}
KUBERNETES_SERVICE_PORT_HTTPS=${KUBERNETES_SERVICE_PORT_HTTPS:?Please specify KUBERNETES_SERVICE_PORT_HTTPS env variable}

BASE_URL="https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT_HTTPS}/api/v1"
CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
RESOURCE_VERSION=$(curl -s "${BASE_URL}/events" --cacert "${CA_CERT}" -H "Authorization: Bearer ${TOKEN}" | jq -r '.metadata.resourceVersion')

trap 'kill -TERM $PID' TERM INT
curl -s "${BASE_URL}/watch/events?resourceVersion=${RESOURCE_VERSION}" --cacert "${CA_CERT}" -H "Authorization: Bearer ${TOKEN}" &
PID=$!
wait $PID
