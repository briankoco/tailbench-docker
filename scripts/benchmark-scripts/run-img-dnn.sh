#!/bin/bash

BENCH_DIR="src/img-dnn"

# Change any options before sourcing config
# This runs for about 3 min
REQS=200000
WARMUP_REQS=5000
QPS=1200
source config.sh

time $ssh_cmd "cd $BENCH_DIR; $run_cmd; cd; $parser $BENCH_DIR/lats.bin > ~/lats.txt"
$scp_cmd:lats.txt img-dnn-lats.txt
