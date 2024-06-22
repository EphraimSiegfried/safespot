#!/bin/bash
start() {
	docker compose -f $COMPOSE_DIR/"$1"/docker-compose.yml up -d
}

# Ensure script stops on errors and missing env variables
set -e
# SCRIPT_DIR=$(dirname $(realpath $0))
# . "$SCRIPT_DIR"/../util.sh
# REQUIRED_VARS=("ADMIN")
# check_vars "${REQUIRED_VARS[@]}"

COMPOSE_DIR=opt/docker

cp -R "$SCRIPT_DIR"/compose $COMPOSE_DIR

docker network create -d bridge proxy
docker network create -d bridge monitor-net

start traefik
start forward-auth
start prometheus
start crowdsec
start node-exporter
start alertmanager
start grafana
start whoami
