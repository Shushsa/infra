
#!/bin/bash

exec 2>&1
set -e

ETC_PROFILE="/etc/profile"
source $ETC_PROFILE &> /dev/null
if [ "$DEBUG_MODE" == "True" ] ; then set -x ; else set +x ; fi

# ensure docker registry exists
KIRA_SETUP_REGISTRY="$KIRA_SETUP/registry-v0.0.9"
if [[ $(${KIRA_SCRIPTS}/container-exists.sh "registry") != "True" ]] || [ ! -f "$KIRA_SETUP_REGISTRY" ] ; then
    echo "Container 'registry' does NOT exist or update is required, creating..."
    ${KIRA_SCRIPTS}/container-delete.sh "registry"
docker run -d \
 -p $KIRA_REGISTRY_PORT:5000 \
 --restart=always \
 --name registry \
 -e REGISTRY_STORAGE_DELETE_ENABLED=true \
 -e REGISTRY_LOG_LEVEL=debug \
 registry:2.7.1

    DOCKER_DAEMON_JSON="/etc/docker/daemon.json"
    rm -f -v $
    if [ "$KIRA_REGISTRY_NAME" == "localhost" ] ; then
        cat > $DOCKER_DAEMON_JSON << EOL
{
  "insecure-registries" : ["http://localhost:$KIRA_REGISTRY_PORT","http://127.0.0.1:$KIRA_REGISTRY_PORT","localhost:$KIRA_REGISTRY_PORT","127.0.0.1:$KIRA_REGISTRY_PORT"]
}
EOL
    else 
        cat > $DOCKER_DAEMON_JSON << EOL
{
  "insecure-registries" : ["$KIRA_REGISTRY_NAME:$KIRA_REGISTRY_PORT","http://$KIRA_REGISTRY_NAME:$KIRA_REGISTRY_PORT","http://localhost:$KIRA_REGISTRY_PORT","http://127.0.0.1:$KIRA_REGISTRY_PORT","localhost:$KIRA_REGISTRY_PORT","127.0.0.1:$KIRA_REGISTRY_PORT"]
}
EOL
    fi
    systemctl restart docker
    touch $KIRA_SETUP_REGISTRY
else
    echo "Container 'registry' already exists."
    docker exec -it registry bin/registry --version
fi

docker ps # list containers
docker images