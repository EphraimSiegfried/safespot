#!/bin/bash

# Install firewall (ufw is an abstraction of iptables)
apt-get update && apt-get upgrade -y
apt-get install ufw -y

ufw default deny incoming

# Allow ssh
ufw allow OpenSSH

# Allow ports 80 & 443 for traefik
ufw allow 80/tcp
ufw allow 443/tcp

# Start the firewall
ufw enable
