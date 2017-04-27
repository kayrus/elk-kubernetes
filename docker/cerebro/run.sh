#!/bin/sh

adduser --home /cerebro --system --ingroup sudo cerebro
chown -R cerebro /cerebro
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

export SERVER_BASEPATH=${SERVER_BASEPATH:-/}
export ELASTICSEARCH_URL=${ELASTICSEARCH_URL:-"http://localhost:9200"}
export CEREBRO_SECRET=${CEREBRO_SECRET:-'ki:s:[[@=Ag?QI`W2jMwkY:eqvrJ]JqoJyi2axj3ZvOv^/KavOT4ViJSv?6YY4[N'}
echo ELASTICSEARCH_URL=${ELASTICSEARCH_URL}
envsubst < /cerebro/conf/routes.tmpl > /cerebro/conf/routes
envsubst < /cerebro/conf/application.conf.tmpl > /cerebro/conf/application.conf

gosu cerebro /cerebro/bin/cerebro "$@" &
PID=$!
trap 'kill -TERM ${PID}' INT TERM
echo "Started Cerebro(${PID})"
wait ${PID}
