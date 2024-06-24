#!/bin/bash

# This script installs unattended-upgrades and executes the reconfigure in a GUI in the terminal

set -e
apt-get install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
