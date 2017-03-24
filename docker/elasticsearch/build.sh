#!/bin/sh -e
IMG=kayrus/docker-elasticsearch-kubernetes:2.4.4
docker build -t $IMG .
docker push $IMG
