#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=1
WARMUPREQS=${WARMUPREQS:-5000}
REQUESTS=${REQUESTS:-10000}
QPS=${QPS:-500}

_REQS=${_REQS:-100000000} # Set this very high; the harness controls maxreqs

if [ ! -z RANDSEED ] ; then
    export TBENCH_RANDSEED=$RANDSEED
fi

TBENCH_WARMUPREQS=${WARMUPREQS} TBENCH_MAXREQS=${REQUESTS} TBENCH_QPS=${QPS} \
    TBENCH_MINSLEEPNS=10000 TBENCH_MNIST_DIR=${DATA_ROOT}/img-dnn/mnist \
    ./img-dnn_integrated -r ${THREADS} \
    -f ${DATA_ROOT}/img-dnn/models/model.xml -n ${_REQS}
