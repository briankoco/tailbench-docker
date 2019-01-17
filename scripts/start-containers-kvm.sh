#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <hostfile"
    exit 1
fi

hostfile=$1
hosts=`awk '{print $1}' $hostfile`
for h in ${hosts[@]}; do
    echo $h
    ssh cc@$h "pushd tailbench-docker/scripts; ./start.sh; popd"
done
