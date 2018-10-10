#!/bin/bash

BENCH_DIR="src/specjbb"

# Change any options before sourcing config
# This runs for about 3 min
REQS=250000
WARMUP_REQS=10000
QPS=1500
source config.sh

time $ssh_cmd "cd $BENCH_DIR; $run_cmd; cd; $parser $BENCH_DIR/lats.bin > ~/lats.txt"
$scp_cmd:lats.txt specjbb-lats.txt
