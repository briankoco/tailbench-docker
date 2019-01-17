#!/bin/bash

if [ $# -eq 1 ]; then
    numa_node=$1
else
    numa_node=-1
fi

TB_DIR="${HOME}/tailbench-docker"
C_HOME="/home/cc"

NODE0_CPUS="0,32,8,40,16,48,24,56,4,36,12,44,20,52,28,60"
NODE1_CPUS="1,33,9,41,17,49,25,57,5,37,13,45,21,53,29,61"
NODE2_CPUS="2,34,10,42,18,50,26,58,6,38,14,46,22,54,30,62"
NODE3_CPUS="3,35,11,43,19,51,27,59,7,39,15,47,23,55,31,63"

if [ $numa_node -eq 0 ]; then
    DOCKER_OPTS="--cpuset-cpus ${NODE0_CPUS} --cpuset-mems 0"
elif [ $numa_node -eq 1 ]; then
    DOCKER_OPTS="--cpuset-cpus ${NODE1_CPUS} --cpuset-mems 1"
elif [ $numa_node -eq 2 ]; then
    DOCKER_OPTS="--cpuset-cpus ${NODE2_CPUS} --cpuset-mems 2"
elif [ $numa_node -eq 3 ]; then
    DOCKER_OPTS="--cpuset-cpus ${NODE3_CPUS} --cpuset-mems 3"
else
    DOCKER_OPTS=""
fi

if [ $numa_node -eq -1 ]; then
    NAME="tailbench"
else
    NAME="tailbench$numa_node"
fi

echo $DOCKER_OPTS

if [ -d /ssd-sde/briankoco/tb-scratch ]; then
    docker run --net host --name $NAME \
        $DOCKER_OPTS \
        -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
        -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
        -v /ssd-sde/briankoco/tb-scratch:${C_HOME}/scratch \
        -d tailbench
else
    docker run --net host --name $NAME \
        $DOCKER_OPTS \
        -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
        -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
        -d tailbench
fi
