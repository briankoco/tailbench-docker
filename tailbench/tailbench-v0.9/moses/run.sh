#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=${THREADS:-1}
QPS=${QPS:-100}
WARMUPREQS=${WARMUPREQS:-500}
REQUESTS=${REQUESTS:-500}

if [ ! -z RANDSEED ] ; then
    export TBENCH_RANDSEED=$RANDSEED
fi

BIN=./bin/moses_integrated

cp moses.ini.template moses.ini
sed -i -e "s#@DATA_ROOT#$DATA_ROOT#g" moses.ini

TBENCH_QPS=${QPS} TBENCH_MAXREQS=${REQUESTS} TBENCH_WARMUPREQS=${WARMUPREQS} \
    TBENCH_MINSLEEPNS=10000 ${BIN} -config ./moses.ini \
    -input-file ${DATA_ROOT}/moses/testTerms \
    -threads ${THREADS} -num-tasks 100000 -verbose 0
