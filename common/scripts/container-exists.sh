#!/bin/bash

exec 2>&1
set -e
set -x

name=$1

# e.g. registry:2
if [[ $(docker ps -a --format '{{.Names}}' | grep -Eq "^${name}\$" || echo False) == "False" ]] ; then
    echo "False"
else
    echo "True"
fi

