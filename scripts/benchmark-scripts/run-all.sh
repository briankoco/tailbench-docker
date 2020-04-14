#!/bin/bash

ts="$(date +"%Y-%m-%d-%H-%M-%S")-results"
mkdir -p $ts

run_exp() {
    local script=$1
    local dirname=$2
    local log="${script:6:-2}log"
    $script &> $log
    mv $log *-lats.txt $dirname
}

HOSTNAME=localhost run_exp ./run-xapian.sh $ts
HOSTNAME=localhost run_exp ./run-masstree.sh $ts
HOSTNAME=localhost run_exp ./run-moses.sh $ts
HOSTNAME=localhost run_exp ./run-sphinx.sh $ts
HOSTNAME=localhost run_exp ./run-img-dnn.sh $ts
HOSTNAME=localhost run_exp ./run-specjbb.sh $ts
HOSTNAME=localhost run_exp ./run-silo.sh $ts
#HOSTNAME=localhost run_exp ./run-shore.sh $ts
