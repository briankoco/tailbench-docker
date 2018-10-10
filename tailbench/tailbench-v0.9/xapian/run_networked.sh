#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

NSERVERS=${NSERVERS:-1}
QPS=${QPS:-500}
WARMUPREQS=${WARMUPREQS:-1000}
REQUESTS=${REQUESTS:-10000}
MINSLEEPNS=${MINSLEEPNS:-100000}
THREADS=${THREADS:-1}

if [ ! -z RANDSEED ] ; then
    export TBENCH_RANDSEED=$RANDSEED
fi


TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    ./xapian_networked_server -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki \
    -r 1000000000 &
echo $! > server.pid

sleep 5 # Wait for server to come up

TBENCH_QPS=${QPS} TBENCH_MINSLEEPNS=100000 \
    TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in \
    ./xapian_networked_client &

echo $! > client.pid

wait $(cat client.pid)

# Clean up
./kill_networked.sh
rm server.pid client.pid
