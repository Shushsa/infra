
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

# ensure docker registry exists
KIRA_SETUP_REGISTRY="$KIRA_SETUP/registry-v0.0.1"
if [[ $(${KIRA_SCRIPTS}/container-exists.sh "registry") != "True" ]] || [ ! -f "$KIRA_SETUP_REGISTRY" ] ; then
    echo "Container 'registry' does NOT exist, creating..."
    ${KIRA_SCRIPTS}/container-delete.sh "registry"
    docker run -d \
 -p $KIRA_REGISTRY_PORT:$KIRA_REGISTRY_PORT \
 --restart=always \
 --name registry \
 -e REGISTRY_STORAGE_DELETE_ENABLED=true \
 registry:2.7.1

    DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
    rm -f -v $DOCKER_DAEMON_JSON
    cat > $DOCKER_DAEMON_JSON << EOL
{
  "insecure-registries" : ["localhost:5000","127.0.0.1:5000"]
}
EOL
    touch $KIRA_SETUP_REGISTRY
else
    echo "Container 'registry' already exists."
    docker exec -it registry bin/registry --version
fi

docker ps # list containers
docker images