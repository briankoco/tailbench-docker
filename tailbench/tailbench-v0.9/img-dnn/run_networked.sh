#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=1
WARMUPREQS=${WARMUPREQS:-5000}
REQUESTS=${REQUESTS:-10000}
QPS=${QPS:-500}

_REQS=${_REQS:-100000000} # Set this very high; the harness controls maxreqs

TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_MAXREQS=${REQUESTS} ./img-dnn_server_networked \
    -r ${THREADS} -f ${DATA_ROOT}/img-dnn/models/model.xml -n ${_REQS} &
echo $! > server.pid

sleep 5 # Wait for server to come up

TBENCH_QPS=${QPS} TBENCH_MNIST_DIR=${DATA_ROOT}/img-dnn/mnist ./img-dnn_client_networked &

echo $! > client.pid

wait $(cat client.pid)
# Clean up
./kill_networked.sh
