#!/bin/bash

TB_DIR="${HOME}/tailbench-docker"
C_HOME="/home/cc"

echo $TB_DIR
echo $C_HOME

docker rm -f tailbench

docker run --net host --name tailbench \
    -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
    -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
    -v ${TB_DIR}/results:${C_HOME}/results \
    -d tailbench
