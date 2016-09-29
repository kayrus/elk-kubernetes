#!/bin/sh

CDIR=$(cd `dirname "$0"` && pwd)
cd "$CDIR"

NAMESPACE="monitoring"

kubectl ${CONTEXT} --namespace="${NAMESPACE}" delete ds fluentd-elasticsearch
kubectl ${CONTEXT} --namespace="${NAMESPACE}" create -f es-fluentd-ds.yaml 
