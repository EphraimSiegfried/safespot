#!/bin/bash

# Ensure script stops on errors and missing env variables
set -e
SCRIPT_DIR=$(dirname $(realpath $0))
. "$SCRIPT_DIR"/../util.sh
REQUIRED_VARS=("ADMIN" "SSH_PUBLIC_KEY")
check_vars "${REQUIRED_VARS[@]}"

# Install ssh server
apt-get update && apt-get upgrade -y
apt-get install openssh-server -y

# Store public key in known hosts
mkdir /home/$ADMIN/.ssh
echo "$SSH_PUBLIC_KEY" >/home/$ADMIN/.ssh/authorized_keys
chmod 700 /home/$ADMIN/.ssh
chmod 600 /home/$ADMIN/.ssh/authorized_keys

# Set the configuration for the ssh server
cp $SCRIPT_DIR/sshd.conf /etc/ssh/sshd_config.d/

# Start the ssh server
systemctl enable ssh --now
