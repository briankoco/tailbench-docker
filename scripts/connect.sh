#!/bin/bash

TB_DIR="${HOME}/tailbench-docker"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i ${TB_DIR}/files/ssh-keys/id_rsa -p 2222 -l cc \
    localhost
