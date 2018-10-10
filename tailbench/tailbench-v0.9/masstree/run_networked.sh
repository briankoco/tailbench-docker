#!/bin/bash

if [[ -z "${NTHREADS}" ]]; then NTHREADS=1; fi

QPS=${QPS:-1000}
REQUESTS=${REQUESTS:-3000}
WARMUPREQS=${WARMUPREQS:-14000}

if [ ! -z RANDSEED ] ; then
    export TBENCH_RANDSEED=$RANDSEED
fi

TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    ./mttest_server_networked -j${NTHREADS} mycsba masstree &
echo $! > server.pid

sleep 5 # Allow server to come up

TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=10000 ./mttest_client_networked &
echo $! > client.pid

wait $(cat client.pid)

# Clean up
./kill_networked.sh
