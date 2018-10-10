#!/bin/bash

BENCH_DIR="src/xapian"

# Change any options before sourcing config
# This runs for about 3 min
REQS=100000
source config.sh

time $ssh_cmd "cd $BENCH_DIR; $run_cmd; cd; $parser $BENCH_DIR/lats.bin > ~/lats.txt"
$scp_cmd:lats.txt xapian-lats.txt
