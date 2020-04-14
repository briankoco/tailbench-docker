#!/bin/bash

TB_DIR="${HOME}/tailbench-docker"
C_HOME="/home/cc"
NAME="tailbench"

cmd="\
docker run --net host --name $NAME \
  -v ${TB_DIR}/tailbench/tailbench.inputs:${C_HOME}/data \
  -v ${TB_DIR}/tailbench/tailbench-v0.9:${C_HOME}/src \
  -d tailbench"

echo $cmd
$cmd
