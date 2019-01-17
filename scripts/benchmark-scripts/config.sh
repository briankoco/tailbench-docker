#!/bin/bash

# Default values that can be overridden by the individual benchmark scripts
RANDSEED=${RANDSEED:-1234}
WARMUP_REQS=${WARMUP_REQS:-1000}
REQS=${REQS:-10000}
QPS=${QPS:-500}
MINSLEEPNS=${MINSLEEPNS:-100000}

TB_DIR="${HOME}/tailbench-docker"
UTILS_DIR="src/utilities"
parser="${UTILS_DIR}/parselats.py"

HOSTNAME=${HOSTNAME:-"localhost"}
USERNAME=${USERNAME:-"cc"}

ssh_cmd="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ${TB_DIR}/files/ssh-keys/id_rsa -p 2222 -l $USERNAME $HOSTNAME"

scp_cmd="scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ${TB_DIR}/files/ssh-keys/id_rsa -P 2222 $USERNAME@$HOSTNAME"

run_cmd="\
    NSERVERS=1 RANDSEED=$RANDSEED WARMUPREQS=$WARMUP_REQS REQUESTS=$REQS QPS=$QPS MINSLEEPNS=$MINSLEEPNS \
    ./run_networked.sh"
