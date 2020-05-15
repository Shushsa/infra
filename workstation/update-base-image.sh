#!/bin/bash

exec 2>&1
set -e
set -x

source /etc/profile

cd $KIRA_INFRA/docker/base-image

docker build --tag base-image ./

docker image ls # list docker images

# create local docker registry
docker run -d \
  -p 5000:5000 \
  --restart=always \
  --name registry \
  registry:2

docker ps # list containers

docker tag base-image:latest localhost:5000/base-image
docker push localhost:5000/base-image


