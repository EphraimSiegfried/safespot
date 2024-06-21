#!/bin/bash
# Ensure script stops on errors and missing env variables
set -e
SCRIPT_DIR=$(dirname $(realpath $0))
. "$SCRIPT_DIR"/../util.sh
REQUIRED_VARS=("ADMIN")
check_vars "${REQUIRED_VARS[@]}"

# Install zsh for a more friendly shell environment
apt-get update && apt-get upgrade -y
apt-get install zsh -y
# Add a new user to the sudo group, create a home directory and set zsh as default shell
useradd -m -g sudo -s /usr/bin/zsh $ADMIN
