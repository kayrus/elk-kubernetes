#!/bin/sh

# provision elasticsearch user

sysctl -w vm.max_map_count=262144 || { echo "Can not set vm.max_map_count sysctl value, exiting..."; exit 1; }

addgroup sudo
adduser -D -g '' elasticsearch
adduser elasticsearch sudo
chown -R elasticsearch /elasticsearch /data
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# allow for memlock
ulimit -l unlimited

killes() {
  trap '' INT TERM
  if [ -z "${ES_PERSISTENT}" ] || [ "${ES_PERSISTENT}" = "false" ] || [ "${ES_PERSISTENT}" = "0" ]; then
    # Data is not persistent, move it out of the current node
    /pre-stop-hook.sh
    RES=$?
    if [ "$RES" -ne 0 ]; then
      echo "Something went wrong (${RES} exit code), manual maintenance is required, hanging forever..."
      sleep 31557600
    fi
  fi
  echo "Shutting down Elasticsearch (${PID})"
  kill -TERM ${PID}
  wait
  echo DONE
}

# run
gosu elasticsearch /elasticsearch/bin/elasticsearch "$@" &
PID=$!
trap 'killes' INT TERM
echo "Started Elasticsearch (${PID})"
wait ${PID}
