#!/bin/bash

start() {
	docker stack deploy -c $COMPOSE_DIR/"$1"/docker-compose.yml traefik-stack
}

systemctl enable docker # docker runs on boot
docker network create --driver overlay --attachable monitor-net

# Ensure script stops on errors and missing env variables
set -e

COMPOSE_DIR=/opt/docker

cp -R ./src/docker/compose $COMPOSE_DIR

touch /opt/docker/forward-auth/traefik-forward-auth
echo "providers.google.client-id=$GOOGLE_CLIENT_ID" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "providers.google.client-secret=$GOOGLE_CLIENT_SECRET" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "secret=" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
sudo docker secret create traefik-forward-auth-v8 $COMPOSE_DIR/forward-auth/traefik-forward-auth # creates the secret for forward-auth

start traefik
start forward-auth
start crowdsec
start prometheus
start node-exporter
start alertmanager
start grafana
start watchtower
start whoami
