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


TBENCH_QPS=${QPS} TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
       TBENCH_MINSLEEPNS=${MINSLEEPNS} TBENCH_TERMS_FILE=${DATA_ROOT}/xapian/terms.in \
       TBENCH_CLIENT_THREADS=$THREADS \
       ./xapian_integrated -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki -r 1000000000

#chrt -r 99 ./xapian_integrated -n ${NSERVERS} -d ${DATA_ROOT}/xapian/wiki -r 1000000000
