#!/bin/bash

exec 2>&1
set -e
set -x

cd $KIRA_INFRA/docker/base-image-v0.0.2

docker build --tag base-image:v0.0.2 ./


