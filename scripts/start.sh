#!/bin/bash

TB_DIR="${HOME}/tailbench-docker"
C_HOME="/home/cc"

if [ -d /ssd-sde/briankoco/tb-scratch ]; then
    docker run --net host --name tailbench \
        -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
        -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
        -v /ssd-sde/briankoco/tb-scratch:${C_HOME}/scratch \
        -d tailbench
else
    docker run --net host --name tailbench \
        -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
        -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
        -d tailbench
fi
