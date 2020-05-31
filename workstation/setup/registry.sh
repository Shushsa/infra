
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"

source $ETC_PROFILE &> /dev/null

[ "$DEBUG_MODE" == "True" ] && set -x
[ "$DEBUG_MODE" == "False" ] && set +x

# ensure docker registry exists
if [[ $(${KIRA_SCRIPTS}/container-exists.sh "registry") != "True" ]] ; then
    echo "Container 'registry' does NOT exist, creating..."
    ${KIRA_SCRIPTS}/container-delete.sh "registry"
docker run -d \
 -p $KIRA_REGISTRY_PORT:$KIRA_REGISTRY_PORT \
 --restart=always \
 --name registry \
 -e REGISTRY_STORAGE_DELETE_ENABLED=true \
 registry:2.7.1
else
    echo "Container 'registry' already exists."
    docker exec -it registry bin/registry --version
fi

docker ps # list containers
docker images ls