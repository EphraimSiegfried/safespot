#!/bin/bash

start() {
	docker stack deploy -c $COMPOSE_DIR/"$1"/docker-compose.yml traefik-stack
}

systemctl enable docker # docker runs on boot
docker network create --driver overlay --attachable monitor-net

# Ensure script stops on errors and missing env variables
set -e
# SCRIPT_DIR=$(dirname $(realpath $0))
# . "$SCRIPT_DIR"/../util.sh
# REQUIRED_VARS=("ADMIN")
# check_vars "${REQUIRED_VARS[@]}"

COMPOSE_DIR=/opt/docker

cp -R "$SCRIPT_DIR"/compose $COMPOSE_DIR

echo "providers.google.client-id=$GOOGLE_CLIENT_ID" >> $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "providers.google.client-secret=$GOOGLE_CLIENT_SECRET" >> $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "secret=" >> $COMPOSE_DIR/forward-auth/traefik-forward-auth

start traefik
start forward-auth
start crowdsec
start prometheus
start node-exporter
start alertmanager
start grafana
start watchtower
start whoami
