#!/bin/bash

pushd ..
docker build . -t tailbench
popd
