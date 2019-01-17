#!/bin/bash

if [ $# -eq 1 ]; then
    numa_node=$1
else
    numa_node=-1
fi

if [ $numa_node -eq -1 ]; then
    NAME="tailbench"
else
    NAME="tailbench$numa_node"
fi

docker rm -f $NAME
