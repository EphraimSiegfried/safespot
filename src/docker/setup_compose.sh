#!/bin/bash

docker network create --driver overlay --attachable monitor-net

start() {
	docker stack deploy -c $COMPOSE_DIR/"$1"/docker-compose.yml traefik-stack
}

# Ensure script stops on errors and missing env variables
set -e
# SCRIPT_DIR=$(dirname $(realpath $0))
# . "$SCRIPT_DIR"/../util.sh
# REQUIRED_VARS=("ADMIN")
# check_vars "${REQUIRED_VARS[@]}"

COMPOSE_DIR=/opt/docker

cp -R "$SCRIPT_DIR"/compose $COMPOSE_DIR

start traefik
start forward-auth
start crowdsec
start prometheus
start node-exporter
start alertmanager
start grafana
start whoami
