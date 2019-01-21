#!/bin/bash

wget http://tailbench.csail.mit.edu/tailbench.inputs.tgz -O tailbench/tailbench.inputs.tgz

pushd tailbench
tar xvf tailbench.inputs.tgz
popd
