#!/bin/bash
set -e

. ./config.sh

SRC=./src
bash $SRC/user/setup_user.sh
bash $SRC/firewall/setup_firewall.sh
bash $SRC/ssh_server/setup_ssh.sh
bash $SRC/docker/install_docker.sh
