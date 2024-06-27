#!/bin/bash

# This script sets up the different compose folders and executes the services, so that everything is running and can be used

# Function for starting each service
start() {
	docker stack deploy -c $COMPOSE_DIR/"$1"/docker-compose.yml traefik-stack
}

systemctl enable docker # docker runs on boot
docker network create --driver overlay --attachable monitor-net # creates the network monitor-net

# Ensure script stops on errors and missing env variables
set -e

# Where the compose files are
COMPOSE_DIR=/opt/docker

# Copies the folder src/docker/compose to /opt/docker
cp -R ./src/docker/compose $COMPOSE_DIR

# Creates the file traefik-forward-auth, adds the three lines used for forward authentication at Google and creates a secret
touch /opt/docker/forward-auth/traefik-forward-auth
echo "providers.google.client-id=$GOOGLE_CLIENT_ID" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "providers.google.client-secret=$GOOGLE_CLIENT_SECRET" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
echo "secret=" | sudo tee -a $COMPOSE_DIR/forward-auth/traefik-forward-auth
sudo docker secret create traefik-forward-auth-v8 $COMPOSE_DIR/forward-auth/traefik-forward-auth # creates the secret for forward-auth

# Create different folders
mkdir /var/log/traefik # log files for traefik
mkdir $COMPOSE_DIR/prometheus/prometheus-data # data folder for prometheus
mkdir $COMPOSE_DIR/grafana/grafana_data # data folder for grafana
mkdir $COMPOSE_DIR/crowdsec/crowdsec/data # data folder for crowdsec
mkdir $COMPOSE_DIR/alertmanager/alertmanager-data # data folder for alertmanager

# Create the ACME certificate file and give it 600 permission
touch $COMPOSE_DIR/traefik/traefik/acme_letsencrypt.json
chmod 600 $COMPOSE_DIR/traefik/traefik/acme_letsencrypt.json

# Starts each of the services we have implemented
start traefik
start forward-auth
start crowdsec
start prometheus
start node-exporter
start alertmanager
start grafana
start watchtower
start whoami
