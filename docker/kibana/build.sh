#!/bin/sh -e
IMG=kayrus/docker-kibana-kubernetes-sentinl:4.6.4
docker build -t $IMG .
docker push $IMG
