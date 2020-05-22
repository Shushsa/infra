#!/bin/bash

exec 2>&1
set -e

name=$1

# e.g. registry:2
if [[ $(docker ps -a --format '{{.Names}}' | grep -Eq "^${name}\$" || echo False) == "False" ]] ; then
    exit 1
else
    echo $(docker inspect --format="{{.Id}}" ${name} 2> /dev/null)
fi