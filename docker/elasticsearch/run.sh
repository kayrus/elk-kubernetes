#!/bin/sh

# provision elasticsearch user
addgroup sudo
adduser -D -g '' elasticsearch
adduser elasticsearch sudo
chown -R elasticsearch /elasticsearch /data
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# allow for memlock
ulimit -l unlimited

trap 'killes' INT TERM

killes() {
  trap '' INT TERM
  /pre-stop-hook.sh
  RES=$?
  if [ "$RES" -ne 0 ]; then
    echo "Something went wrong (${RES} exit code), manual maintenance is required, hanging forever..."
    sleep 31557600
  fi
  echo "Shutting down Elasticsearch (${PID})"
  kill -TERM ${PID}
  wait
  echo DONE
}

# run
gosu elasticsearch /elasticsearch/bin/elasticsearch &
PID=$!
echo "Started Elasticsearch (${PID})"
wait ${PID}
