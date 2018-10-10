#!/bin/bash

BENCH_DIR="src/shore"

# Change any options before sourcing config
# This runs for about 3 min
REQS=60000
WARMUP_REQS=10000
QPS=400
source config.sh

time $ssh_cmd "cd $BENCH_DIR; $run_cmd; cd; $parser $BENCH_DIR/lats.bin > ~/lats.txt"
$scp_cmd:lats.txt shore-lats.txt
