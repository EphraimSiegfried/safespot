#!/bin/bash

# This script installs docker and docker compose since each service is in it's own container

set -e
# Add Docker's official GPG key:
apt-get update && apt-get upgrade -y

apt-get -y install \
	apt-transport-https \
	ca-certificates \
	curl \
	gnupg-agent \
	software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update

apt-get install docker-ce docker-ce-cli containerd.io -y

curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) | sudo tee /usr/local/bin/docker-compose >/dev/null

chmod +x /usr/local/bin/docker-compose
