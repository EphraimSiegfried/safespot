#!/bin/bash

# Sets up SSH

# Ensure script stops on errors and missing env variables
set -e

# Install ssh server
apt-get update && apt-get upgrade -y
apt-get install openssh-server -y

# Set the configuration for the ssh server
SCRIPT_DIR=$(dirname $(realpath $0))
cp $SCRIPT_DIR/sshd.conf /etc/ssh/sshd_config.d/

# Start the ssh server
systemctl enable ssh --now
