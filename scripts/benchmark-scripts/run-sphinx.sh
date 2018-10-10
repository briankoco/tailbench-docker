#!/bin/bash

BENCH_DIR="src/sphinx"

# Change any options before sourcing config
# This runs for about 3 min
REQS=150
WARMUP_REQS=10
QPS=1
source config.sh

time $ssh_cmd "cd $BENCH_DIR; $run_cmd; cd; $parser $BENCH_DIR/lats.bin > ~/lats.txt"
$scp_cmd:lats.txt sphinx-lats.txt
